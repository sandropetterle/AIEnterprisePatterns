using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Security.Claims;
using System.Text;
using AIEnterprisePatterns.Api.Authentication;
using AIEnterprisePatterns.Data;
using AwesomeAssertions;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.IdentityModel.JsonWebTokens;
using Microsoft.IdentityModel.Protocols;
using Microsoft.IdentityModel.Protocols.OpenIdConnect;
using Microsoft.IdentityModel.Tokens;

namespace AIEnterprisePatterns.Api.Tests.IntegrationTests;

/// <summary>
/// Issue #144 regression guards. Unlike PatternEndpointsTests these run the app's REAL
/// authentication wiring from Program.cs — no TestAuthHandler — because substituting a
/// test scheme is exactly what hid the "no scheme registered → 500" defect.
/// </summary>
public class AuthPipelineTests : IClassFixture<WebApplicationFactory<Program>>
{
    private const string Issuer = "https://issuer.test/tenant/v2.0";
    private const string AppIdUri = "api://aipatterns-api";
    private const string ApiClientId = "11111111-2222-3333-4444-555555555555";

    private static readonly SymmetricSecurityKey SigningKey =
        new(Encoding.UTF8.GetBytes("auth-pipeline-tests-signing-key-0123456789abcdef"));

    private readonly WebApplicationFactory<Program> _factory;

    public AuthPipelineTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
    }

    private WebApplicationFactory<Program> CreateFactory(
        string environment,
        Dictionary<string, string?> settings,
        Action<IServiceCollection>? configureServices = null)
    {
        return _factory.WithWebHostBuilder(builder =>
        {
            builder.UseEnvironment(environment);
            // UseSetting, not ConfigureAppConfiguration: Program.cs reads builder.Configuration
            // before Build(), and only host settings are visible that early under minimal hosting.
            builder.UseSetting("ConnectionStrings:DefaultConnection", "");
            foreach (var (key, value) in settings)
                builder.UseSetting(key, value);
            builder.ConfigureServices(services =>
            {
                // EF Core 9+: remove the provider configuration too, not just the options (see PatternEndpointsTests)
                services.RemoveAll<DbContextOptions<ApplicationDbContext>>();
                services.RemoveAll<IDbContextOptionsConfiguration<ApplicationDbContext>>();

                services.AddDbContext<ApplicationDbContext>(options =>
                    options.UseInMemoryDatabase($"AuthPipelineTestDb_{Guid.NewGuid()}"));

                configureServices?.Invoke(services);
            });
        });
    }

    /// <summary>
    /// Real JwtBearer against a static OIDC configuration, so no metadata is fetched over the network.
    /// </summary>
    private HttpClient CreateJwtBearerClient(bool overrideValidAudiences = true)
    {
        var settings = new Dictionary<string, string?>
        {
            ["Authentication:Authority"] = Issuer,
            ["Authentication:Audience"] = AppIdUri
        };
        if (overrideValidAudiences)
            settings["Authentication:ValidAudiences:0"] = ApiClientId;

        var factory = CreateFactory("Production", settings, services =>
            services.PostConfigure<JwtBearerOptions>(JwtBearerDefaults.AuthenticationScheme, options =>
            {
                var configuration = new OpenIdConnectConfiguration { Issuer = Issuer };
                configuration.SigningKeys.Add(SigningKey);
                options.Configuration = configuration;
                options.ConfigurationManager =
                    new StaticConfigurationManager<OpenIdConnectConfiguration>(configuration);
            }));

        return factory.CreateClient();
    }

    private static string CreateToken(string audience, SecurityKey? key = null, params string[] roles)
    {
        var claims = new List<Claim> { new("sub", "user-1"), new("name", "Test User") };
        claims.AddRange(roles.Select(r => new Claim("roles", r)));

        return new JsonWebTokenHandler().CreateToken(new SecurityTokenDescriptor
        {
            Issuer = Issuer,
            Audience = audience,
            Subject = new ClaimsIdentity(claims),
            Expires = DateTime.UtcNow.AddMinutes(10),
            SigningCredentials = new SigningCredentials(key ?? SigningKey, SecurityAlgorithms.HmacSha256)
        });
    }

    private static HttpRequestMessage Bearer(HttpMethod method, string url, string token)
    {
        var request = new HttpRequestMessage(method, url);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
        return request;
    }

    public static TheoryData<string, string> ProtectedEndpoints => new()
    {
        { "GET", "/api/auth/me" },
        { "POST", "/api/patterns" },
        { "PUT", $"/api/patterns/{Guid.NewGuid()}" },
        { "DELETE", $"/api/patterns/{Guid.NewGuid()}" }
    };

    [Theory]
    [MemberData(nameof(ProtectedEndpoints))]
    public async Task Development_WithoutAuthority_ProtectedEndpoint_Returns401Not500(string method, string url)
    {
        var client = CreateFactory("Development", new() { ["Authentication:Authority"] = "" }).CreateClient();

        var request = new HttpRequestMessage(new HttpMethod(method), url);
        if (method is "POST" or "PUT")
            request.Content = JsonContent.Create(new { });

        var response = await client.SendAsync(request);

        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task Development_WithoutAuthority_UsesUnconfiguredFallbackScheme()
    {
        var factory = CreateFactory("Development", new() { ["Authentication:Authority"] = "" });

        var schemes = factory.Services.GetRequiredService<IAuthenticationSchemeProvider>();
        var defaultScheme = await schemes.GetDefaultChallengeSchemeAsync();

        defaultScheme!.Name.Should().Be(UnconfiguredAuthenticationHandler.SchemeName);
        (await schemes.GetSchemeAsync(JwtBearerDefaults.AuthenticationScheme)).Should().BeNull();
    }

    [Fact]
    public async Task Development_WithoutAuthority_PublicEndpoint_StillWorks()
    {
        var client = CreateFactory("Development", new() { ["Authentication:Authority"] = "" }).CreateClient();

        var response = await client.GetAsync("/api/patterns");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
    }

    [Theory]
    [InlineData("Production")]
    [InlineData("Staging")]
    public void NonDevelopment_WithoutAuthority_RefusesToStart(string environment)
    {
        var factory = CreateFactory(environment, new() { ["Authentication:Authority"] = "" });

        var act = () => factory.CreateClient();

        act.Should().Throw<InvalidOperationException>()
            .WithMessage("*Authentication:Authority is not configured*");
    }

    [Fact]
    public void Production_WithAuthorityButNoAudience_RefusesToStart()
    {
        var factory = CreateFactory("Production", new()
        {
            ["Authentication:Authority"] = Issuer,
            ["Authentication:Audience"] = "",
            // appsettings.Production.json commits a ValidAudiences entry; blank it so no audience remains
            ["Authentication:ValidAudiences:0"] = ""
        });

        var act = () => factory.CreateClient();

        act.Should().Throw<InvalidOperationException>()
            .WithMessage("*Authentication:Audience is empty*");
    }

    [Theory]
    [MemberData(nameof(ProtectedEndpoints))]
    public async Task JwtBearer_NoToken_ProtectedEndpoint_Returns401(string method, string url)
    {
        var client = CreateJwtBearerClient();

        var request = new HttpRequestMessage(new HttpMethod(method), url);
        if (method is "POST" or "PUT")
            request.Content = JsonContent.Create(new { });

        var response = await client.SendAsync(request);

        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task JwtBearer_ForgedToken_Returns401InvalidToken()
    {
        var client = CreateJwtBearerClient();
        var forgedKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes("attacker-controlled-key-0123456789abcdefgh"));

        var response = await client.SendAsync(
            Bearer(HttpMethod.Get, "/api/auth/me", CreateToken(AppIdUri, forgedKey)));

        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
        response.Headers.WwwAuthenticate.ToString().Should().Contain("invalid_token");
    }

    [Theory]
    [InlineData(AppIdUri)]
    [InlineData(ApiClientId)]
    public async Task JwtBearer_ValidToken_EitherConfiguredAudience_IsAccepted(string audience)
    {
        var client = CreateJwtBearerClient();

        var response = await client.SendAsync(
            Bearer(HttpMethod.Get, "/api/auth/me", CreateToken(audience, roles: "Viewer")));

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var body = await response.Content.ReadAsStringAsync();
        using var json = System.Text.Json.JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        json.RootElement.GetProperty("id").GetString().Should().Be("user-1");
        json.RootElement.GetProperty("name").GetString().Should().Be("Test User");
        json.RootElement.GetProperty("roles").EnumerateArray().Select(r => r.GetString())
            .Should().Equal("Viewer");
    }

    // Without MapInboundClaims = false, JwtBearer renames "roles" to the ClaimTypes.Role URI, so
    // RequireRole (RoleClaimType = "roles") never matches and every real Editor/Admin gets 403.
    [Theory]
    [InlineData("Editor")]
    [InlineData("Admin")]
    public async Task JwtBearer_ValidTokenWithEditorRole_PassesAuthorization(string role)
    {
        var client = CreateJwtBearerClient();

        var request = Bearer(HttpMethod.Post, "/api/patterns", CreateToken(AppIdUri, roles: role));
        request.Content = JsonContent.Create(new { });
        var response = await client.SendAsync(request);

        // Empty body fails validation — reaching 400 proves authorization succeeded.
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task JwtBearer_AdminToken_Delete_PassesAuthorization()
    {
        var client = CreateJwtBearerClient();

        var response = await client.SendAsync(
            Bearer(HttpMethod.Delete, $"/api/patterns/{Guid.NewGuid()}", CreateToken(AppIdUri, roles: "Admin")));

        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    // The prod API app (AIPatterns-API) has requestedAccessTokenVersion = 2, so real tokens carry its
    // client-ID GUID as aud, not the App ID URI. Accepting it is committed in appsettings.Production.json
    // (issue #144 follow-up) — this fails if that value is dropped or changed.
    [Fact]
    public async Task JwtBearer_Production_CommittedConfig_AcceptsRealApiClientIdAudience()
    {
        var client = CreateJwtBearerClient(overrideValidAudiences: false);

        var response = await client.SendAsync(Bearer(HttpMethod.Get, "/api/auth/me",
            CreateToken("862a328f-19ea-4d05-b4c3-54d260bea9ec", roles: "Admin")));

        response.StatusCode.Should().Be(HttpStatusCode.OK);
    }

    [Fact]
    public async Task JwtBearer_ValidSignatureWrongAudience_Returns401()
    {
        var client = CreateJwtBearerClient();

        var response = await client.SendAsync(
            Bearer(HttpMethod.Get, "/api/auth/me", CreateToken("api://some-other-api")));

        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task JwtBearer_ValidTokenWithoutEditorRole_CreatePattern_Returns403()
    {
        var client = CreateJwtBearerClient();

        var request = Bearer(HttpMethod.Post, "/api/patterns", CreateToken(AppIdUri, roles: "Viewer"));
        request.Content = JsonContent.Create(new { });
        var response = await client.SendAsync(request);

        response.StatusCode.Should().Be(HttpStatusCode.Forbidden);
    }
}
