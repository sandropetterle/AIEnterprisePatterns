using System.Net;
using System.Text;
using System.Text.Json;
using AIEnterprisePatterns.Api.Tests.Helpers;
using AIEnterprisePatterns.Data;
using AwesomeAssertions;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;

namespace AIEnterprisePatterns.Api.Tests.IntegrationTests;

/// <summary>
/// Characterization tests for the 400 body of invalid POST/PUT pattern requests (Decision 94).
/// Written against FluentValidation.AspNetCore auto-validation and kept green after the switch to
/// explicit validation, so the ValidationProblemDetails contract (status, type, title, PascalCase
/// error keys, FluentValidation messages) cannot drift silently.
/// </summary>
public class ValidationResponseShapeTests : IClassFixture<WebApplicationFactory<Program>>
{
    private const string ValidationType = "https://tools.ietf.org/html/rfc9110#section-15.5.1";
    private const string ValidationTitle = "One or more validation errors occurred.";
    private const string InvalidCategoryMessage =
        "Invalid category. Valid values: Architecture, DesignPatterns, AIPrompts, BestPractices, CodeGeneration, Testing, Security, Performance";

    private readonly HttpClient _client;

    public ValidationResponseShapeTests(WebApplicationFactory<Program> factory)
    {
        var databaseName = $"ValidationShapeDb_{Guid.NewGuid()}";
        _client = factory.WithWebHostBuilder(builder =>
        {
            builder.ConfigureServices(services =>
            {
                services.RemoveAll<DbContextOptions<ApplicationDbContext>>();
                services.RemoveAll<IDbContextOptionsConfiguration<ApplicationDbContext>>();
                services.AddDbContext<ApplicationDbContext>(options => options.UseInMemoryDatabase(databaseName));
                services.AddAuthentication(TestAuthHandler.SchemeName)
                    .AddScheme<AuthenticationSchemeOptions, TestAuthHandler>(TestAuthHandler.SchemeName, _ => { });
            });
        }).CreateClient();
    }

    private async Task<(HttpResponseMessage Response, JsonElement Body)> SendAsync(string method, string json)
    {
        // PUT targets a non-existent id: a 400 (not 404) proves validation runs before the service call.
        var url = method == "POST" ? "/api/patterns" : $"/api/patterns/{Guid.NewGuid()}";
        var request = new HttpRequestMessage(new HttpMethod(method), url).WithRole("Editor");
        request.Content = new StringContent(json, Encoding.UTF8, "application/json");

        var response = await _client.SendAsync(request);
        var body = JsonDocument.Parse(await response.Content.ReadAsStringAsync()).RootElement.Clone();
        return (response, body);
    }

    private static Dictionary<string, string[]> AssertValidationProblem(HttpResponseMessage response, JsonElement body)
    {
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        response.Content.Headers.ContentType!.MediaType.Should().Be("application/problem+json");
        body.GetProperty("type").GetString().Should().Be(ValidationType);
        body.GetProperty("title").GetString().Should().Be(ValidationTitle);
        body.GetProperty("status").GetInt32().Should().Be(400);
        body.TryGetProperty("traceId", out _).Should().BeTrue();

        return body.GetProperty("errors").EnumerateObject().ToDictionary(
            p => p.Name,
            p => p.Value.EnumerateArray().Select(e => e.GetString()!).ToArray());
    }

    // Rules only FluentValidation enforces: the body must be exactly the FluentValidation error.
    [Theory]
    [InlineData("POST", """{"title":"T","shortDescription":"D","category":"InvalidCategory","tags":[]}""", "Category", InvalidCategoryMessage)]
    [InlineData("PUT", """{"title":"T","shortDescription":"D","category":"InvalidCategory","tags":[]}""", "Category", InvalidCategoryMessage)]
    [InlineData("POST", """{"title":"T","shortDescription":"D","category":"Architecture","tags":["a","b","c","d","e","f","g","h","i","j","k"]}""", "Tags", "Maximum 10 tags allowed.")]
    [InlineData("PUT", """{"title":"T","shortDescription":"D","category":"Architecture","tags":["a","b","c","d","e","f","g","h","i","j","k"]}""", "Tags", "Maximum 10 tags allowed.")]
    [InlineData("POST", """{"title":"T","shortDescription":"D","category":"Architecture","tags":["ok"," "]}""", "Tags[1]", "Tags must not be empty or whitespace.")]
    [InlineData("PUT", """{"title":"T","shortDescription":"D","category":"Architecture","tags":["ok"," "]}""", "Tags[1]", "Tags must not be empty or whitespace.")]
    public async Task FluentValidationRuleFailure_Returns400WithExactErrors(string method, string json, string key, string message)
    {
        var (response, body) = await SendAsync(method, json);

        var errors = AssertValidationProblem(response, body);

        errors.Should().ContainSingle();
        errors.Should().ContainKey(key);
        errors[key].Should().Equal(message);
    }

    // Rules DataAnnotations also enforce: same PascalCase keys and the DataAnnotations message.
    [Theory]
    [InlineData("POST")]
    [InlineData("PUT")]
    public async Task RequiredFieldsMissing_Returns400KeyedByPascalCasePropertyName(string method)
    {
        var (response, body) = await SendAsync(method, """{"title":"","shortDescription":"","category":"","tags":[]}""");

        var errors = AssertValidationProblem(response, body);

        errors.Keys.Should().BeEquivalentTo("Title", "ShortDescription", "Category");
        errors["Title"].Should().Contain("The Title field is required.");
        errors["ShortDescription"].Should().Contain("The ShortDescription field is required.");
        errors["Category"].Should().Contain("The Category field is required.");
    }
}
