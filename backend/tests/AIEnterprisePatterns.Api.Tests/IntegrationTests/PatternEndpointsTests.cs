using System.Net;
using System.Net.Http.Json;
using AIEnterprisePatterns.Api.DTOs;
using AIEnterprisePatterns.Api.Tests.Helpers;
using AIEnterprisePatterns.Core.Entities;
using AIEnterprisePatterns.Core.Enums;
using AIEnterprisePatterns.Data;
using FluentAssertions;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace AIEnterprisePatterns.Api.Tests.IntegrationTests;

public class PatternEndpointsTests : IClassFixture<WebApplicationFactory<Program>>, IDisposable
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;
    private readonly IServiceScope _scope;
    private readonly ApplicationDbContext _context;
    private static readonly string DatabaseName = $"TestDb_{Guid.NewGuid()}";

    public PatternEndpointsTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory.WithWebHostBuilder(builder =>
        {
            builder.ConfigureServices(services =>
            {
                var descriptor = services.SingleOrDefault(
                    d => d.ServiceType == typeof(DbContextOptions<ApplicationDbContext>));
                if (descriptor != null)
                    services.Remove(descriptor);

                services.AddDbContext<ApplicationDbContext>(options =>
                    options.UseInMemoryDatabase(DatabaseName));

                services.AddAuthentication(TestAuthHandler.SchemeName)
                    .AddScheme<AuthenticationSchemeOptions, TestAuthHandler>(TestAuthHandler.SchemeName, _ => { });
            });
        });

        _client = _factory.CreateClient();
        _scope = _factory.Services.CreateScope();
        _context = _scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

        if (!_context.Patterns.Any())
            SeedTestData();
    }

    private static HttpRequestMessage AdminRequest(HttpMethod method, string url, HttpContent? content = null)
    {
        var req = new HttpRequestMessage(method, url).WithRole("Admin");
        if (content != null) req.Content = content;
        return req;
    }

    private static HttpRequestMessage EditorRequest(HttpMethod method, string url, HttpContent? content = null)
    {
        var req = new HttpRequestMessage(method, url).WithRole("Editor");
        if (content != null) req.Content = content;
        return req;
    }

    [Fact]
    public async Task GetPatterns_ShouldReturnPaginatedResults()
    {
        var response = await _client.GetAsync("/api/patterns?page=1&pageSize=10");
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<PaginatedResponse<PatternListDto>>();
        result!.Patterns.Should().NotBeEmpty();
        result.CurrentPage.Should().Be(1);
    }

    [Fact]
    public async Task GetPatterns_ShouldFilterByCategory()
    {
        var response = await _client.GetAsync("/api/patterns?category=Architecture");
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<PaginatedResponse<PatternListDto>>();
        result!.Patterns.Should().OnlyContain(p => p.Category == "Architecture");
    }

    [Fact]
    public async Task GetPatterns_ShouldFilterByTags()
    {
        var response = await _client.GetAsync("/api/patterns?tags=Testing");
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<PaginatedResponse<PatternListDto>>();
        result!.Patterns.Should().NotBeEmpty();
        result.Patterns.Should().OnlyContain(p => p.Tags.Contains("Testing"));
    }

    [Fact]
    public async Task GetPatterns_ShouldSearchByTitleOrDescription()
    {
        var response = await _client.GetAsync("/api/patterns?search=Test");
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<PaginatedResponse<PatternListDto>>();
        result!.Patterns.Should().NotBeEmpty();
    }

    [Fact]
    public async Task GetPatterns_ShouldSortByVotes()
    {
        var response = await _client.GetAsync("/api/patterns?sortBy=votes");
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<PaginatedResponse<PatternListDto>>();
        result!.Patterns.Should().BeInDescendingOrder(p => p.VoteCount);
    }

    [Fact]
    public async Task GetFeaturedPatterns_ShouldReturnOnlyFeatured()
    {
        var response = await _client.GetAsync("/api/patterns/featured");
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<List<PatternListDto>>();
        result.Should().NotBeEmpty();
        result.Should().OnlyContain(p => p.IsFeatured);
    }

    [Fact]
    public async Task GetTrendingPatterns_ShouldReturnOnlyTrending()
    {
        var response = await _client.GetAsync("/api/patterns/trending");
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<List<PatternListDto>>();
        result.Should().NotBeEmpty();
        result.Should().OnlyContain(p => p.IsTrending);
    }

    [Fact]
    public async Task GetPatternBySlug_ShouldReturnPattern()
    {
        var pattern = CreateTestPattern("Test Pattern", "test-slug");
        _context.Patterns.Add(pattern);
        await _context.SaveChangesAsync();

        var response = await _client.GetAsync("/api/patterns/test-slug");
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<PatternDetailDto>();
        result!.Slug.Should().Be("test-slug");
    }

    [Fact]
    public async Task GetPatternBySlug_ShouldReturn404WhenNotFound()
    {
        var response = await _client.GetAsync("/api/patterns/nonexistent-slug");
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task VoteForPattern_ShouldIncrementVoteCount()
    {
        var pattern = CreateTestPattern("Vote Test", "vote-test");
        pattern.VoteCount = 10;
        _context.Patterns.Add(pattern);
        await _context.SaveChangesAsync();

        var response = await _client.PostAsync($"/api/patterns/{pattern.Id}/vote", null);
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<VoteResponse>();
        result!.VoteCount.Should().Be(11);
    }

    [Fact]
    public async Task VoteForPattern_ShouldReturn404WhenNotFound()
    {
        var response = await _client.PostAsync($"/api/patterns/{Guid.NewGuid()}/vote", null);
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task GetRelatedPatterns_ShouldReturn200WithRelatedPatterns()
    {
        // arch-pattern-test is Architecture — high-votes (Performance) shares archTag
        var response = await _client.GetAsync("/api/patterns/arch-pattern-test/related");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<List<PatternListDto>>();
        result.Should().NotBeNull();
        result.Should().NotContain(p => p.Slug == "arch-pattern-test");
    }

    [Fact]
    public async Task GetRelatedPatterns_ShouldReturn200WithEmptyListForUnknownSlug()
    {
        var response = await _client.GetAsync("/api/patterns/nonexistent-slug/related");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<List<PatternListDto>>();
        result.Should().BeEmpty();
    }

    [Fact]
    public async Task CreatePattern_ShouldCreateNewPattern()
    {
        var dto = new CreatePatternDto
        {
            Title = "New Pattern", ShortDescription = "Desc", FullContent = "Content",
            Category = "Architecture", Author = "Author", Tags = new List<string> { "Testing", "New" }
        };
        var response = await _client.SendAsync(EditorRequest(HttpMethod.Post, "/api/patterns", JsonContent.Create(dto)));
        response.StatusCode.Should().Be(HttpStatusCode.Created);
        var result = await response.Content.ReadFromJsonAsync<PatternDetailDto>();
        result!.Title.Should().Be("New Pattern");
        result.Tags.Should().Contain("Testing");
    }

    [Fact]
    public async Task CreatePattern_ShouldReturn400ForInvalidCategory()
    {
        var dto = new CreatePatternDto
        {
            Title = "P", ShortDescription = "D", Category = "InvalidCategory", Tags = new List<string>()
        };
        var response = await _client.SendAsync(EditorRequest(HttpMethod.Post, "/api/patterns", JsonContent.Create(dto)));
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task CreatePattern_ShouldReturn401WhenUnauthenticated()
    {
        var dto = new CreatePatternDto
        {
            Title = "P", ShortDescription = "D", Category = "Architecture", Tags = new List<string>()
        };
        var response = await _client.PostAsJsonAsync("/api/patterns", dto);
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task UpdatePattern_ShouldUpdateExistingPattern()
    {
        var pattern = CreateTestPattern("Original Title", "original-slug");
        _context.Patterns.Add(pattern);
        await _context.SaveChangesAsync();

        var dto = new UpdatePatternDto
        {
            Title = "Updated Title", ShortDescription = "Updated", FullContent = "Updated content",
            Category = "Security", Author = "Author", IsFeatured = true, IsTrending = true,
            Tags = new List<string> { "Security" }
        };
        var response = await _client.SendAsync(EditorRequest(HttpMethod.Put, $"/api/patterns/{pattern.Id}", JsonContent.Create(dto)));
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<PatternDetailDto>();
        result!.Title.Should().Be("Updated Title");
        result.IsFeatured.Should().BeTrue();
    }

    [Fact]
    public async Task UpdatePattern_ShouldReturn404WhenNotFound()
    {
        var dto = new UpdatePatternDto
        {
            Title = "T", ShortDescription = "D", Category = "Architecture", Tags = new List<string>()
        };
        var response = await _client.SendAsync(EditorRequest(HttpMethod.Put, $"/api/patterns/{Guid.NewGuid()}", JsonContent.Create(dto)));
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task UpdatePattern_ShouldReturn401WhenUnauthenticated()
    {
        var dto = new UpdatePatternDto
        {
            Title = "T", ShortDescription = "D", Category = "Architecture", Tags = new List<string>()
        };
        var response = await _client.PutAsJsonAsync($"/api/patterns/{Guid.NewGuid()}", dto);
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task DeletePattern_ShouldDeletePattern()
    {
        var pattern = CreateTestPattern("To Delete", "to-delete");
        _context.Patterns.Add(pattern);
        await _context.SaveChangesAsync();

        var response = await _client.SendAsync(AdminRequest(HttpMethod.Delete, $"/api/patterns/{pattern.Id}"));
        response.StatusCode.Should().Be(HttpStatusCode.NoContent);

        _context.ChangeTracker.Clear();
        (await _context.Patterns.FindAsync(pattern.Id)).Should().BeNull();
    }

    [Fact]
    public async Task DeletePattern_ShouldReturn404WhenNotFound()
    {
        var response = await _client.SendAsync(AdminRequest(HttpMethod.Delete, $"/api/patterns/{Guid.NewGuid()}"));
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task DeletePattern_ShouldReturn401WhenUnauthenticated()
    {
        var response = await _client.DeleteAsync($"/api/patterns/{Guid.NewGuid()}");
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task DeletePattern_ShouldReturn403WhenEditorTriesToDelete()
    {
        var pattern = CreateTestPattern("Cannot Delete", "cannot-delete");
        _context.Patterns.Add(pattern);
        await _context.SaveChangesAsync();

        var response = await _client.SendAsync(EditorRequest(HttpMethod.Delete, $"/api/patterns/{pattern.Id}"));
        response.StatusCode.Should().Be(HttpStatusCode.Forbidden);
    }

    private void SeedTestData()
    {
        var testingTag = new Tag { Id = Guid.NewGuid(), Name = "Testing" };
        var archTag = new Tag { Id = Guid.NewGuid(), Name = "Architecture" };
        var secTag = new Tag { Id = Guid.NewGuid(), Name = "Security" };
        _context.Tags.AddRange(testingTag, archTag, secTag);
        _context.SaveChanges();

        _context.Patterns.AddRange(
            CreateTestPattern("Architecture Pattern Test", "arch-pattern-test", PatternCategory.Architecture, 50, true, false, new[] { archTag }),
            CreateTestPattern("Design Pattern with Testing", "design-testing", PatternCategory.DesignPatterns, 40, false, true, new[] { testingTag }),
            CreateTestPattern("Security Test Pattern", "security-test", PatternCategory.Security, 35, false, true, new[] { secTag }),
            CreateTestPattern("High Votes Pattern", "high-votes", PatternCategory.Performance, 100, false, false, new[] { archTag }),
            CreateTestPattern("Featured and Trending", "featured-trending", PatternCategory.AIPrompts, 75, true, true, new[] { testingTag, archTag })
        );
        _context.SaveChanges();
    }

    private Pattern CreateTestPattern(
        string title, string slug,
        PatternCategory category = PatternCategory.Architecture,
        int voteCount = 0, bool isFeatured = false, bool isTrending = false,
        Tag[]? tags = null) => new Pattern
    {
        Id = Guid.NewGuid(), Title = title, Slug = slug,
        ShortDescription = $"Description for {title}", FullContent = $"Full content for {title}",
        Category = category, Author = "Test Author",
        CreatedDate = DateTime.UtcNow, UpdatedDate = DateTime.UtcNow,
        VoteCount = voteCount, Status = PatternStatus.Published,
        IsFeatured = isFeatured, IsTrending = isTrending,
        Tags = tags?.ToList() ?? new List<Tag>()
    };

    public void Dispose()
    {
        _scope?.Dispose();
        _context?.Dispose();
    }
}