using AIEnterprisePatterns.Core.Entities;
using AIEnterprisePatterns.Core.Enums;
using AIEnterprisePatterns.Data.Repositories;
using FluentAssertions;
using Microsoft.EntityFrameworkCore;

namespace AIEnterprisePatterns.Data.Tests.Repositories;

public class PatternRepositoryTests : IDisposable
{
    private readonly ApplicationDbContext _context;
    private readonly PatternRepository _sut;

    public PatternRepositoryTests()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        _context = new ApplicationDbContext(options);
        _sut = new PatternRepository(_context);

        // Seed test data
        SeedTestData();
    }

    #region GetPatternsAsync Tests

    [Fact]
    public async Task GetPatternsAsync_ShouldReturnPaginatedResults()
    {
        // Act
        var result = await _sut.GetPatternsAsync(1, 10, null, null, null, null);

        // Assert
        result.Should().NotBeNull();
        result.Items.Should().HaveCountGreaterThan(0);
        result.CurrentPage.Should().Be(1);
        result.PageSize.Should().Be(10);
        result.TotalCount.Should().BeGreaterThan(0);
    }

    [Fact]
    public async Task GetPatternsAsync_ShouldFilterByCategory()
    {
        // Act
        var result = await _sut.GetPatternsAsync(1, 10, null, "Architecture", null, null);

        // Assert
        result.Items.Should().OnlyContain(p => p.Category == PatternCategory.Architecture);
        result.Items.Should().NotBeEmpty();
    }

    [Fact]
    public async Task GetPatternsAsync_ShouldFilterByTags()
    {
        // Arrange
        var tags = new List<string> { "Testing" };

        // Act
        var result = await _sut.GetPatternsAsync(1, 10, null, null, tags, null);

        // Assert
        result.Items.Should().NotBeEmpty();
        result.Items.Should().OnlyContain(p => p.Tags.Any(t => tags.Contains(t.Name)));
    }

    [Fact]
    public async Task GetPatternsAsync_ShouldSearchByTitle()
    {
        // Act
        var result = await _sut.GetPatternsAsync(1, 10, null, null, null, "Architecture");

        // Assert
        result.Items.Should().NotBeEmpty();
        result.Items.Should().OnlyContain(p =>
            p.Title.Contains("Architecture", StringComparison.OrdinalIgnoreCase) ||
            p.ShortDescription.Contains("Architecture", StringComparison.OrdinalIgnoreCase) ||
            p.Tags.Any(t => t.Name.Contains("Architecture", StringComparison.OrdinalIgnoreCase)));
    }

    [Fact]
    public async Task GetPatternsAsync_WithSearchTerm_SearchesFullContent()
    {
        // Arrange - Add a pattern with unique content only in FullContent
        var pattern = CreatePattern("Regular Title", "full-content-search-slug");
        pattern.FullContent = "UniqueFullContentToken12345";
        _context.Patterns.Add(pattern);
        await _context.SaveChangesAsync();

        // Act
        var result = await _sut.GetPatternsAsync(1, 10, null, null, null, "UniqueFullContentToken12345");

        // Assert
        result.Items.Should().NotBeEmpty();
        result.Items.Should().Contain(p => p.Slug == "full-content-search-slug");
    }

    [Fact]
    public async Task GetPatternsAsync_WithSearchTerm_SearchesTags()
    {
        // Arrange - tag3 is "Performance", seeded in SeedTestData
        // Act
        var result = await _sut.GetPatternsAsync(1, 10, null, null, null, "Performance");

        // Assert
        result.Items.Should().NotBeEmpty();
        result.Items.Should().OnlyContain(p =>
            p.Title.Contains("Performance", StringComparison.OrdinalIgnoreCase) ||
            p.ShortDescription.Contains("Performance", StringComparison.OrdinalIgnoreCase) ||
            p.Tags.Any(t => t.Name.Contains("Performance", StringComparison.OrdinalIgnoreCase)));
    }

    [Fact]
    public async Task GetPatternsAsync_WithDateRange_FiltersCorrectly()
    {
        // Arrange
        var oldPattern = CreatePattern("Old Pattern", "old-pattern");
        oldPattern.CreatedDate = DateTime.UtcNow.AddDays(-30);
        var newPattern = CreatePattern("New Pattern", "new-pattern");
        newPattern.CreatedDate = DateTime.UtcNow.AddDays(-1);
        _context.Patterns.AddRange(oldPattern, newPattern);
        await _context.SaveChangesAsync();

        var from = DateTime.UtcNow.AddDays(-7);
        var to = DateTime.UtcNow;

        // Act
        var result = await _sut.GetPatternsAsync(1, 100, null, null, null, null, from, to);

        // Assert
        result.Items.Should().Contain(p => p.Slug == "new-pattern");
        result.Items.Should().NotContain(p => p.Slug == "old-pattern");
    }

    [Fact]
    public async Task GetPatternsAsync_WithDateFrom_OnlyReturnsNewerPatterns()
    {
        // Arrange
        var oldPattern = CreatePattern("Old Pattern B", "old-pattern-b");
        oldPattern.CreatedDate = DateTime.UtcNow.AddDays(-60);
        _context.Patterns.Add(oldPattern);
        await _context.SaveChangesAsync();

        var from = DateTime.UtcNow.AddDays(-10);

        // Act
        var result = await _sut.GetPatternsAsync(1, 100, null, null, null, null, from);

        // Assert
        result.Items.Should().NotContain(p => p.Slug == "old-pattern-b");
    }

    [Fact]
    public async Task GetPatternsAsync_WithTagModeAll_RequiresAllTags()
    {
        // Arrange - seeded: "Architecture Pattern 1" has tag "Architecture"
        // "Design Pattern with Testing" has tag "Testing"
        // No pattern has both "Architecture" AND "Testing"
        var tags = new List<string> { "Architecture", "Testing" };

        // Act
        var result = await _sut.GetPatternsAsync(1, 10, null, null, tags, null, tagMode: "all");

        // Assert
        result.Items.Should().BeEmpty();
    }

    [Fact]
    public async Task GetPatternsAsync_WithTagModeAll_ReturnsPatternWithAllTags()
    {
        // Arrange - create a pattern that has BOTH tags
        var tag1 = _context.Tags.First(t => t.Name == "Architecture");
        var tag2 = _context.Tags.First(t => t.Name == "Testing");
        var multiTagPattern = CreatePattern("Multi Tag Pattern", "multi-tag-pattern", tags: new[] { tag1, tag2 });
        _context.Patterns.Add(multiTagPattern);
        await _context.SaveChangesAsync();

        var tags = new List<string> { "Architecture", "Testing" };

        // Act
        var result = await _sut.GetPatternsAsync(1, 10, null, null, tags, null, tagMode: "all");

        // Assert
        result.Items.Should().Contain(p => p.Slug == "multi-tag-pattern");
    }

    [Fact]
    public async Task GetPatternsAsync_ShouldSortByVotes()
    {
        // Act
        var result = await _sut.GetPatternsAsync(1, 10, "votes", null, null, null);

        // Assert
        result.Items.Should().BeInDescendingOrder(p => p.VoteCount);
    }

    [Fact]
    public async Task GetPatternsAsync_ShouldSortAlphabetically()
    {
        // Act
        var result = await _sut.GetPatternsAsync(1, 10, "alphabetical", null, null, null);

        // Assert
        result.Items.Should().BeInAscendingOrder(p => p.Title);
    }

    [Fact]
    public async Task GetPatternsAsync_ShouldSortByNewestByDefault()
    {
        // Act
        var result = await _sut.GetPatternsAsync(1, 10, null, null, null, null);

        // Assert
        result.Items.Should().BeInDescendingOrder(p => p.CreatedDate);
    }

    [Fact]
    public async Task GetPatternsAsync_ShouldPaginateCorrectly()
    {
        // Act
        var page1 = await _sut.GetPatternsAsync(1, 2, null, null, null, null);
        var page2 = await _sut.GetPatternsAsync(2, 2, null, null, null, null);

        // Assert
        page1.Items.Should().HaveCount(2);
        page2.Items.Should().NotBeEmpty();
        page1.Items.Should().NotIntersectWith(page2.Items);
    }

    [Fact]
    public async Task GetPatternsAsync_ShouldOnlyReturnPublishedPatterns()
    {
        // Arrange - Add a draft pattern
        var draftPattern = CreatePattern("Draft Pattern", "draft-pattern");
        draftPattern.Status = PatternStatus.Draft;
        _context.Patterns.Add(draftPattern);
        await _context.SaveChangesAsync();

        // Act
        var result = await _sut.GetPatternsAsync(1, 100, null, null, null, null);

        // Assert
        result.Items.Should().OnlyContain(p => p.Status == PatternStatus.Published);
        result.Items.Should().NotContain(p => p.Id == draftPattern.Id);
    }

    [Fact]
    public async Task GetPatternsAsync_ShouldIncludeTags()
    {
        // Act
        var result = await _sut.GetPatternsAsync(1, 10, null, null, null, null);

        // Assert
        result.Items.Should().NotBeEmpty();
        result.Items.First().Tags.Should().NotBeNull();
    }

    #endregion

    #region GetBySlugAsync Tests

    [Fact]
    public async Task GetBySlugAsync_ShouldReturnPattern()
    {
        // Arrange
        var pattern = CreatePattern("Test Pattern", "test-pattern-slug");
        _context.Patterns.Add(pattern);
        await _context.SaveChangesAsync();

        // Act
        var result = await _sut.GetBySlugAsync("test-pattern-slug");

        // Assert
        result.Should().NotBeNull();
        result!.Slug.Should().Be("test-pattern-slug");
        result.Tags.Should().NotBeNull();
    }

    [Fact]
    public async Task GetBySlugAsync_ShouldReturnNullWhenNotFound()
    {
        // Act
        var result = await _sut.GetBySlugAsync("nonexistent-slug");

        // Assert
        result.Should().BeNull();
    }

    [Fact]
    public async Task GetBySlugAsync_ShouldOnlyReturnPublished()
    {
        // Arrange
        var draftPattern = CreatePattern("Draft Pattern", "draft-slug");
        draftPattern.Status = PatternStatus.Draft;
        _context.Patterns.Add(draftPattern);
        await _context.SaveChangesAsync();

        // Act
        var result = await _sut.GetBySlugAsync("draft-slug");

        // Assert
        result.Should().BeNull();
    }

    #endregion

    #region GetByIdAsync Tests

    [Fact]
    public async Task GetByIdAsync_ShouldReturnPattern()
    {
        // Arrange
        var pattern = CreatePattern("Test Pattern", "test-slug");
        _context.Patterns.Add(pattern);
        await _context.SaveChangesAsync();

        // Act
        var result = await _sut.GetByIdAsync(pattern.Id);

        // Assert
        result.Should().NotBeNull();
        result!.Id.Should().Be(pattern.Id);
        result.Tags.Should().NotBeNull();
    }

    [Fact]
    public async Task GetByIdAsync_ShouldReturnNullWhenNotFound()
    {
        // Act
        var result = await _sut.GetByIdAsync(Guid.NewGuid());

        // Assert
        result.Should().BeNull();
    }

    [Fact]
    public async Task GetByIdAsync_ShouldReturnDraftPatterns()
    {
        // Arrange
        var draftPattern = CreatePattern("Draft Pattern", "draft-slug");
        draftPattern.Status = PatternStatus.Draft;
        _context.Patterns.Add(draftPattern);
        await _context.SaveChangesAsync();

        // Act
        var result = await _sut.GetByIdAsync(draftPattern.Id);

        // Assert
        result.Should().NotBeNull();
        result!.Status.Should().Be(PatternStatus.Draft);
    }

    #endregion

    #region GetFeaturedPatternsAsync Tests

    [Fact]
    public async Task GetFeaturedPatternsAsync_ShouldReturnOnlyFeatured()
    {
        // Act
        var result = await _sut.GetFeaturedPatternsAsync();

        // Assert
        result.Should().NotBeEmpty();
        result.Should().OnlyContain(p => p.IsFeatured);
        result.Should().OnlyContain(p => p.Status == PatternStatus.Published);
    }

    [Fact]
    public async Task GetFeaturedPatternsAsync_ShouldOrderByVotes()
    {
        // Act
        var result = await _sut.GetFeaturedPatternsAsync();

        // Assert
        result.Should().BeInDescendingOrder(p => p.VoteCount);
    }

    #endregion

    #region GetTrendingPatternsAsync Tests

    [Fact]
    public async Task GetTrendingPatternsAsync_ShouldReturnOnlyTrending()
    {
        // Act
        var result = await _sut.GetTrendingPatternsAsync();

        // Assert
        result.Should().NotBeEmpty();
        result.Should().OnlyContain(p => p.IsTrending);
        result.Should().OnlyContain(p => p.Status == PatternStatus.Published);
    }

    [Fact]
    public async Task GetTrendingPatternsAsync_ShouldOrderByVotes()
    {
        // Act
        var result = await _sut.GetTrendingPatternsAsync();

        // Assert
        result.Should().BeInDescendingOrder(p => p.VoteCount);
    }

    #endregion

    #region GetRelatedPatternsAsync Tests

    [Fact]
    public async Task GetRelatedPatternsAsync_ShouldReturnSameCategoryPatterns()
    {
        // arch-1 (Architecture) should get arch-2 (Architecture) as related
        var result = await _sut.GetRelatedPatternsAsync("arch-1");

        result.Should().NotBeEmpty();
        result.Should().NotContain(p => p.Slug == "arch-1");
        result.Should().Contain(p => p.Slug == "arch-2");
    }

    [Fact]
    public async Task GetRelatedPatternsAsync_ShouldExcludeCurrentPattern()
    {
        var result = await _sut.GetRelatedPatternsAsync("arch-1");

        result.Should().NotContain(p => p.Slug == "arch-1");
    }

    [Fact]
    public async Task GetRelatedPatternsAsync_ShouldReturnEmptyForUnknownSlug()
    {
        var result = await _sut.GetRelatedPatternsAsync("nonexistent-slug");

        result.Should().BeEmpty();
    }

    [Fact]
    public async Task GetRelatedPatternsAsync_ShouldRespectLimit()
    {
        var result = await _sut.GetRelatedPatternsAsync("arch-1", limit: 1);

        result.Should().HaveCount(1);
    }

    [Fact]
    public async Task GetRelatedPatternsAsync_ShouldIncludeTagMatchesForCrossCategory()
    {
        // Arrange: add pattern with unique category but shares "Architecture" tag
        var archTag = _context.Tags.First(t => t.Name == "Architecture");
        var uniquePattern = CreatePattern("Unique Category Pattern", "unique-cat-pattern",
            PatternCategory.AIPrompts, tags: new[] { archTag });
        _context.Patterns.Add(uniquePattern);
        await _context.SaveChangesAsync();

        // unique-cat-pattern has no same-category peers, but shares "Architecture" tag
        var result = await _sut.GetRelatedPatternsAsync("unique-cat-pattern");

        result.Should().NotBeEmpty();
        result.Should().NotContain(p => p.Slug == "unique-cat-pattern");
    }

    [Fact]
    public async Task GetRelatedPatternsAsync_ShouldNotReturnDraftPatterns()
    {
        // Arrange: add a draft in same category as arch-1
        var draftPattern = CreatePattern("Draft Architecture", "draft-arch", PatternCategory.Architecture);
        draftPattern.Status = PatternStatus.Draft;
        _context.Patterns.Add(draftPattern);
        await _context.SaveChangesAsync();

        var result = await _sut.GetRelatedPatternsAsync("arch-1");

        result.Should().NotContain(p => p.Slug == "draft-arch");
        result.Should().OnlyContain(p => p.Status == PatternStatus.Published);
    }

    [Fact]
    public async Task GetRelatedPatternsAsync_ShouldOrderSameCategoryFirst()
    {
        // arch-1 is Architecture; arch-2 is also Architecture (same category)
        // performance-1 is Performance+Performance-tag (no tag overlap with arch-1)
        var result = await _sut.GetRelatedPatternsAsync("arch-1", limit: 5);

        // All same-category patterns should appear before cross-category ones
        var sameCategoryPatterns = result.Where(p => p.Category == PatternCategory.Architecture).ToList();
        var crossCategoryPatterns = result.Where(p => p.Category != PatternCategory.Architecture).ToList();

        if (sameCategoryPatterns.Count > 0 && crossCategoryPatterns.Count > 0)
        {
            var lastSameCategoryIndex = result.FindLastIndex(p => p.Category == PatternCategory.Architecture);
            var firstCrossCategoryIndex = result.FindIndex(p => p.Category != PatternCategory.Architecture);
            lastSameCategoryIndex.Should().BeLessThan(firstCrossCategoryIndex);
        }
    }

    #endregion

    #region AddAsync Tests

    [Fact]
    public async Task AddAsync_ShouldAddPattern()
    {
        // Arrange
        var pattern = CreatePattern("New Pattern", "new-pattern");

        // Act
        var result = await _sut.AddAsync(pattern);
        await _context.SaveChangesAsync();

        // Assert
        var saved = await _context.Patterns.FindAsync(pattern.Id);
        saved.Should().NotBeNull();
        saved!.Title.Should().Be("New Pattern");
    }

    #endregion

    #region UpdateAsync Tests

    [Fact]
    public async Task UpdateAsync_ShouldUpdatePattern()
    {
        // Arrange
        var pattern = CreatePattern("Original Title", "original-slug");
        _context.Patterns.Add(pattern);
        await _context.SaveChangesAsync();

        pattern.Title = "Updated Title";

        // Act
        await _sut.UpdateAsync(pattern);
        await _context.SaveChangesAsync();

        // Assert
        var updated = await _context.Patterns.FindAsync(pattern.Id);
        updated.Should().NotBeNull();
        updated!.Title.Should().Be("Updated Title");
    }

    #endregion

    #region DeleteAsync Tests

    [Fact]
    public async Task DeleteAsync_ShouldDeletePattern()
    {
        // Arrange
        var pattern = CreatePattern("To Delete", "to-delete");
        _context.Patterns.Add(pattern);
        await _context.SaveChangesAsync();

        // Act
        var result = await _sut.DeleteAsync(pattern.Id);
        await _context.SaveChangesAsync();

        // Assert
        result.Should().BeTrue();
        var deleted = await _context.Patterns.FindAsync(pattern.Id);
        deleted.Should().BeNull();
    }

    [Fact]
    public async Task DeleteAsync_ShouldReturnFalseWhenNotFound()
    {
        // Act
        var result = await _sut.DeleteAsync(Guid.NewGuid());

        // Assert
        result.Should().BeFalse();
    }

    #endregion

    #region IncrementVoteCountAsync Tests

    // NOTE: ExecuteUpdateAsync is not supported by InMemory provider
    // These tests are covered by integration tests which use a real database
    // See: PatternEndpointsTests.VoteForPattern_ShouldIncrementVoteCount

    #endregion

    #region Helper Methods

    private void SeedTestData()
    {
        var tag1 = new Tag { Id = Guid.NewGuid(), Name = "Testing" };
        var tag2 = new Tag { Id = Guid.NewGuid(), Name = "Architecture" };
        var tag3 = new Tag { Id = Guid.NewGuid(), Name = "Performance" };

        _context.Tags.AddRange(tag1, tag2, tag3);

        var patterns = new List<Pattern>
        {
            CreatePattern("Architecture Pattern 1", "arch-1", PatternCategory.Architecture, 50, true, false, new[] { tag2 }),
            CreatePattern("Architecture Pattern 2", "arch-2", PatternCategory.Architecture, 30, false, false, new[] { tag2 }),
            CreatePattern("Design Pattern with Testing", "design-1", PatternCategory.DesignPatterns, 40, false, true, new[] { tag1 }),
            CreatePattern("Security Pattern", "security-1", PatternCategory.Security, 35, false, true, new[] { tag3 }),
            CreatePattern("Performance Pattern", "performance-1", PatternCategory.Performance, 25, true, false, new[] { tag3 }),
        };

        _context.Patterns.AddRange(patterns);
        _context.SaveChanges();
    }

    private Pattern CreatePattern(
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
        _context.Dispose();
    }
}
