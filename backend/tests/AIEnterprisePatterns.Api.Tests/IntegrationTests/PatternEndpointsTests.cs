using System.Net;
using System.Net.Http.Json;
using AIEnterprisePatterns.Api.DTOs;
using AIEnterprisePatterns.Core.Entities;
using AIEnterprisePatterns.Core.Enums;
using AIEnterprisePatterns.Data;
using FluentAssertions;
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
    private static readonly string DatabaseName = $"TestDb_{Guid.NewGuid()}"; // Shared across all contexts in this test class

    public PatternEndpointsTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory.WithWebHostBuilder(builder =>
        {
            builder.ConfigureServices(services =>
            {
                // Remove existing DbContext registration
                var descriptor = services.SingleOrDefault(
                    d => d.ServiceType == typeof(DbContextOptions<ApplicationDbContext>));
                if (descriptor != null)
                    services.Remove(descriptor);

                // Add in-memory database for testing - use shared database name
                services.AddDbContext<ApplicationDbContext>(options =>
                {
                    options.UseInMemoryDatabase(DatabaseName);
                });
            });
        });

        _client = _factory.CreateClient();
        _scope = _factory.Services.CreateScope();
        _context = _scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

        // Seed test data explicitly (only if database is empty)
        if (!_context.Patterns.Any())
        {
            SeedTestData();
        }
    }

    #region GET /api/patterns Tests

    [Fact]
    public async Task GetPatterns_ShouldReturnPaginatedResults()
    {
        // Act
        var response = await _client.GetAsync("/api/patterns?page=1&pageSize=10");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<PaginatedResponse<PatternListDto>>();
        result.Should().NotBeNull();
        result!.Patterns.Should().NotBeEmpty();
        result.CurrentPage.Should().Be(1);
        result.PageSize.Should().Be(10);
    }

    [Fact]
    public async Task GetPatterns_ShouldFilterByCategory()
    {
        // Act
        var response = await _client.GetAsync("/api/patterns?category=Architecture");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<PaginatedResponse<PatternListDto>>();
        result!.Patterns.Should().OnlyContain(p => p.Category == "Architecture");
    }

    [Fact]
    public async Task GetPatterns_ShouldFilterByTags()
    {
        // Act
        var response = await _client.GetAsync("/api/patterns?tags=Testing");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<PaginatedResponse<PatternListDto>>();
        result!.Patterns.Should().NotBeEmpty();
        result.Patterns.Should().OnlyContain(p => p.Tags.Contains("Testing"));
    }

    [Fact]
    public async Task GetPatterns_ShouldSearchByTitleOrDescription()
    {
        // Act
        var response = await _client.GetAsync("/api/patterns?search=Test");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<PaginatedResponse<PatternListDto>>();
        result!.Patterns.Should().NotBeEmpty();
    }

    [Fact]
    public async Task GetPatterns_ShouldSortByVotes()
    {
        // Act
        var response = await _client.GetAsync("/api/patterns?sortBy=votes");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<PaginatedResponse<PatternListDto>>();
        result!.Patterns.Should().BeInDescendingOrder(p => p.VoteCount);
    }

    #endregion

    #region GET /api/patterns/featured Tests

    [Fact]
    public async Task GetFeaturedPatterns_ShouldReturnOnlyFeatured()
    {
        // Act
        var response = await _client.GetAsync("/api/patterns/featured");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<List<PatternListDto>>();
        result.Should().NotBeEmpty();
        result.Should().OnlyContain(p => p.IsFeatured);
    }

    #endregion

    #region GET /api/patterns/trending Tests

    [Fact]
    public async Task GetTrendingPatterns_ShouldReturnOnlyTrending()
    {
        // Act
        var response = await _client.GetAsync("/api/patterns/trending");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<List<PatternListDto>>();
        result.Should().NotBeEmpty();
        result.Should().OnlyContain(p => p.IsTrending);
    }

    #endregion

    #region GET /api/patterns/{slug} Tests

    [Fact]
    public async Task GetPatternBySlug_ShouldReturnPattern()
    {
        // Arrange
        var pattern = CreateTestPattern("Test Pattern", "test-slug");
        _context.Patterns.Add(pattern);
        await _context.SaveChangesAsync();

        // Act
        var response = await _client.GetAsync("/api/patterns/test-slug");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<PatternDetailDto>();
        result.Should().NotBeNull();
        result!.Slug.Should().Be("test-slug");
        result.FullContent.Should().NotBeNullOrEmpty();
    }

    [Fact]
    public async Task GetPatternBySlug_ShouldReturn404WhenNotFound()
    {
        // Act
        var response = await _client.GetAsync("/api/patterns/nonexistent-slug");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    #endregion

    #region POST /api/patterns/{id}/vote Tests

    [Fact]
    public async Task VoteForPattern_ShouldIncrementVoteCount()
    {
        // Arrange
        var pattern = CreateTestPattern("Vote Test", "vote-test");
        pattern.VoteCount = 10;
        _context.Patterns.Add(pattern);
        await _context.SaveChangesAsync();

        // Act
        var response = await _client.PostAsync($"/api/patterns/{pattern.Id}/vote", null);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<VoteResponse>();
        result.Should().NotBeNull();
        result!.VoteCount.Should().Be(11);
        result.PatternId.Should().Be(pattern.Id);
    }

    [Fact]
    public async Task VoteForPattern_ShouldReturn404WhenNotFound()
    {
        // Act
        var response = await _client.PostAsync($"/api/patterns/{Guid.NewGuid()}/vote", null);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    #endregion

    #region POST /api/patterns Tests

    [Fact]
    public async Task CreatePattern_ShouldCreateNewPattern()
    {
        // Arrange
        var createDto = new CreatePatternDto
        {
            Title = "New Pattern",
            ShortDescription = "New description",
            FullContent = "Full content",
            Category = "Architecture",
            Author = "Test Author",
            Tags = new List<string> { "Testing", "New" }
        };

        // Act
        var response = await _client.PostAsJsonAsync("/api/patterns", createDto);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Created);
        var result = await response.Content.ReadFromJsonAsync<PatternDetailDto>();
        result.Should().NotBeNull();
        result!.Title.Should().Be("New Pattern");
        result.Slug.Should().Be("new-pattern");
        result.Tags.Should().Contain("Testing");
        result.Tags.Should().Contain("New");
    }

    [Fact]
    public async Task CreatePattern_ShouldReturn400ForInvalidCategory()
    {
        // Arrange
        var createDto = new CreatePatternDto
        {
            Title = "New Pattern",
            ShortDescription = "Description",
            Category = "InvalidCategory",
            Tags = new List<string>()
        };

        // Act
        var response = await _client.PostAsJsonAsync("/api/patterns", createDto);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }

    #endregion

    #region PUT /api/patterns/{id} Tests

    [Fact]
    public async Task UpdatePattern_ShouldUpdateExistingPattern()
    {
        // Arrange
        var pattern = CreateTestPattern("Original Title", "original-slug");
        _context.Patterns.Add(pattern);
        await _context.SaveChangesAsync();

        var updateDto = new UpdatePatternDto
        {
            Title = "Updated Title",
            ShortDescription = "Updated description",
            FullContent = "Updated content",
            Category = "Security",
            Author = "Updated Author",
            IsFeatured = true,
            IsTrending = true,
            Tags = new List<string> { "Security" }
        };

        // Act
        var response = await _client.PutAsJsonAsync($"/api/patterns/{pattern.Id}", updateDto);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<PatternDetailDto>();
        result.Should().NotBeNull();
        result!.Title.Should().Be("Updated Title");
        result.Category.Should().Be("Security");
        result.IsFeatured.Should().BeTrue();
        result.IsTrending.Should().BeTrue();
    }

    [Fact]
    public async Task UpdatePattern_ShouldReturn404WhenNotFound()
    {
        // Arrange
        var updateDto = new UpdatePatternDto
        {
            Title = "Updated",
            ShortDescription = "Updated",
            Category = "Architecture",
            Tags = new List<string>()
        };

        // Act
        var response = await _client.PutAsJsonAsync($"/api/patterns/{Guid.NewGuid()}", updateDto);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    #endregion

    #region DELETE /api/patterns/{id} Tests

    [Fact]
    public async Task DeletePattern_ShouldDeletePattern()
    {
        // Arrange
        var pattern = CreateTestPattern("To Delete", "to-delete");
        _context.Patterns.Add(pattern);
        await _context.SaveChangesAsync();
        var patternId = pattern.Id;

        // Act
        var response = await _client.DeleteAsync($"/api/patterns/{patternId}");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NoContent);

        // Clear change tracker to force a fresh query from the database
        _context.ChangeTracker.Clear();
        var deleted = await _context.Patterns.FindAsync(patternId);
        deleted.Should().BeNull();
    }

    [Fact]
    public async Task DeletePattern_ShouldReturn404WhenNotFound()
    {
        // Act
        var response = await _client.DeleteAsync($"/api/patterns/{Guid.NewGuid()}");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    #endregion

    #region Helper Methods

    private void SeedTestData()
    {
        // Create test tags explicitly
        var testingTag = new Tag { Id = Guid.NewGuid(), Name = "Testing" };
        var architectureTag = new Tag { Id = Guid.NewGuid(), Name = "Architecture" };
        var securityTag = new Tag { Id = Guid.NewGuid(), Name = "Security" };

        _context.Tags.AddRange(testingTag, architectureTag, securityTag);
        _context.SaveChanges();

        // Create test patterns with diverse data for filtering tests
        var patterns = new List<Pattern>
        {
            // Featured pattern with Architecture tag (for category and featured tests)
            CreateTestPattern("Architecture Pattern Test", "arch-pattern-test", PatternCategory.Architecture, 50, true, false, new[] { architectureTag }),

            // Trending pattern with Testing tag (for tag filtering and trending tests)
            CreateTestPattern("Design Pattern with Testing", "design-testing", PatternCategory.DesignPatterns, 40, false, true, new[] { testingTag }),

            // Security pattern, also trending (for category and trending tests)
            CreateTestPattern("Security Test Pattern", "security-test", PatternCategory.Security, 35, false, true, new[] { securityTag }),

            // Additional pattern with high votes (for sorting tests)
            CreateTestPattern("High Votes Pattern", "high-votes", PatternCategory.Performance, 100, false, false, new[] { architectureTag }),

            // Featured AND trending (for both tests)
            CreateTestPattern("Featured and Trending", "featured-trending", PatternCategory.AIPrompts, 75, true, true, new[] { testingTag, architectureTag })
        };

        _context.Patterns.AddRange(patterns);
        _context.SaveChanges();
    }

    private Pattern CreateTestPattern(
        string title,
        string slug,
        PatternCategory category = PatternCategory.Architecture,
        int voteCount = 0,
        bool isFeatured = false,
        bool isTrending = false,
        Tag[]? tags = null)
    {
        return new Pattern
        {
            Id = Guid.NewGuid(),
            Title = title,
            Slug = slug,
            ShortDescription = $"Description for {title}",
            FullContent = $"Full content for {title}",
            Category = category,
            Author = "Test Author",
            CreatedDate = DateTime.UtcNow,
            UpdatedDate = DateTime.UtcNow,
            VoteCount = voteCount,
            Status = PatternStatus.Published,
            IsFeatured = isFeatured,
            IsTrending = isTrending,
            Tags = tags?.ToList() ?? new List<Tag>()
        };
    }

    #endregion

    public void Dispose()
    {
        _scope?.Dispose();
        _context?.Dispose();
    }
}
