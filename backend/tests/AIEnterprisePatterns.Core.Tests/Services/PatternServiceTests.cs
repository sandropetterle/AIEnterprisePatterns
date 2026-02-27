using AIEnterprisePatterns.Core.Entities;
using AIEnterprisePatterns.Core.Enums;
using AIEnterprisePatterns.Core.Interfaces;
using AIEnterprisePatterns.Core.Services;
using AIEnterprisePatterns.Core.ValueObjects;
using FluentAssertions;
using Microsoft.Extensions.Caching.Memory;
using Moq;

namespace AIEnterprisePatterns.Core.Tests.Services;

public class PatternServiceTests
{
    private readonly Mock<IPatternRepository> _patternRepositoryMock;
    private readonly Mock<ITagRepository> _tagRepositoryMock;
    private readonly Mock<IUnitOfWork> _unitOfWorkMock;
    private readonly IMemoryCache _cache;
    private readonly FakeTimeProvider _timeProvider;
    private readonly PatternService _sut;

    public PatternServiceTests()
    {
        _patternRepositoryMock = new Mock<IPatternRepository>();
        _tagRepositoryMock = new Mock<ITagRepository>();
        _unitOfWorkMock = new Mock<IUnitOfWork>();
        _cache = new MemoryCache(new MemoryCacheOptions());
        _timeProvider = new FakeTimeProvider(new DateTimeOffset(2024, 1, 15, 10, 0, 0, TimeSpan.Zero));

        _sut = new PatternService(
            _patternRepositoryMock.Object,
            _tagRepositoryMock.Object,
            _unitOfWorkMock.Object,
            _cache,
            _timeProvider);
    }

    #region GetPatternsAsync Tests

    [Fact]
    public async Task GetPatternsAsync_ShouldDelegateToRepository()
    {
        // Arrange
        var expectedResult = new PaginatedResult<Pattern>
        {
            Items = new List<Pattern>(),
            TotalCount = 0,
            CurrentPage = 1,
            PageSize = 10
        };
        _patternRepositoryMock
            .Setup(r => r.GetPatternsAsync(1, 10, null, null, null, null,
                It.IsAny<DateTime?>(), It.IsAny<DateTime?>(), It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(expectedResult);

        // Act
        var result = await _sut.GetPatternsAsync(1, 10, null, null, null, null);

        // Assert
        result.Should().Be(expectedResult);
        _patternRepositoryMock.Verify(r => r.GetPatternsAsync(1, 10, null, null, null, null,
            It.IsAny<DateTime?>(), It.IsAny<DateTime?>(), It.IsAny<string>(), It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task GetPatternsAsync_ShouldPassAllParametersToRepository()
    {
        // Arrange
        var tags = new List<string> { "tag1", "tag2" };
        var expectedResult = new PaginatedResult<Pattern>
        {
            Items = new List<Pattern>(),
            TotalCount = 0,
            CurrentPage = 2,
            PageSize = 20
        };
        _patternRepositoryMock
            .Setup(r => r.GetPatternsAsync(2, 20, "votes", "Architecture", tags, "search",
                It.IsAny<DateTime?>(), It.IsAny<DateTime?>(), It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(expectedResult);

        // Act
        var result = await _sut.GetPatternsAsync(2, 20, "votes", "Architecture", tags, "search");

        // Assert
        result.Should().Be(expectedResult);
        _patternRepositoryMock.Verify(r => r.GetPatternsAsync(2, 20, "votes", "Architecture", tags, "search",
            It.IsAny<DateTime?>(), It.IsAny<DateTime?>(), It.IsAny<string>(), It.IsAny<CancellationToken>()), Times.Once);
    }

    #endregion

    #region GetBySlugAsync Tests

    [Fact]
    public async Task GetBySlugAsync_ShouldDelegateToRepository()
    {
        // Arrange
        var slug = "test-pattern";
        var expectedPattern = CreateTestPattern();
        _patternRepositoryMock
            .Setup(r => r.GetBySlugAsync(slug, default))
            .ReturnsAsync(expectedPattern);

        // Act
        var result = await _sut.GetBySlugAsync(slug);

        // Assert
        result.Should().Be(expectedPattern);
        _patternRepositoryMock.Verify(r => r.GetBySlugAsync(slug, default), Times.Once);
    }

    [Fact]
    public async Task GetBySlugAsync_ShouldReturnNullWhenNotFound()
    {
        // Arrange
        _patternRepositoryMock
            .Setup(r => r.GetBySlugAsync("nonexistent", default))
            .ReturnsAsync((Pattern?)null);

        // Act
        var result = await _sut.GetBySlugAsync("nonexistent");

        // Assert
        result.Should().BeNull();
    }

    #endregion

    #region GetFeaturedPatternsAsync Tests

    [Fact]
    public async Task GetFeaturedPatternsAsync_ShouldCacheResult()
    {
        // Arrange
        var patterns = new List<Pattern> { CreateTestPattern() };
        _patternRepositoryMock
            .Setup(r => r.GetFeaturedPatternsAsync(default))
            .ReturnsAsync(patterns);

        // Act
        var result1 = await _sut.GetFeaturedPatternsAsync();
        var result2 = await _sut.GetFeaturedPatternsAsync();

        // Assert
        result1.Should().BeEquivalentTo(patterns);
        result2.Should().BeEquivalentTo(patterns);
        _patternRepositoryMock.Verify(r => r.GetFeaturedPatternsAsync(default), Times.Once);
    }

    [Fact]
    public async Task GetFeaturedPatternsAsync_ShouldReturnEmptyListWhenCacheReturnsNull()
    {
        // Arrange
        _patternRepositoryMock
            .Setup(r => r.GetFeaturedPatternsAsync(default))
            .ReturnsAsync((List<Pattern>)null!);

        // Act
        var result = await _sut.GetFeaturedPatternsAsync();

        // Assert
        result.Should().BeEmpty();
    }

    #endregion

    #region GetTrendingPatternsAsync Tests

    [Fact]
    public async Task GetTrendingPatternsAsync_ShouldCacheResult()
    {
        // Arrange
        var patterns = new List<Pattern> { CreateTestPattern() };
        _patternRepositoryMock
            .Setup(r => r.GetTrendingPatternsAsync(default))
            .ReturnsAsync(patterns);

        // Act
        var result1 = await _sut.GetTrendingPatternsAsync();
        var result2 = await _sut.GetTrendingPatternsAsync();

        // Assert
        result1.Should().BeEquivalentTo(patterns);
        result2.Should().BeEquivalentTo(patterns);
        _patternRepositoryMock.Verify(r => r.GetTrendingPatternsAsync(default), Times.Once);
    }

    [Fact]
    public async Task GetTrendingPatternsAsync_ShouldReturnEmptyListWhenCacheReturnsNull()
    {
        // Arrange
        _patternRepositoryMock
            .Setup(r => r.GetTrendingPatternsAsync(default))
            .ReturnsAsync((List<Pattern>)null!);

        // Act
        var result = await _sut.GetTrendingPatternsAsync();

        // Assert
        result.Should().BeEmpty();
    }

    #endregion

    #region GetRelatedPatternsAsync Tests

    [Fact]
    public async Task GetRelatedPatternsAsync_ShouldCacheResult()
    {
        // Arrange
        var slug = "test-pattern";
        var patterns = new List<Pattern> { CreateTestPattern() };
        _patternRepositoryMock
            .Setup(r => r.GetRelatedPatternsAsync(slug, It.IsAny<int>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(patterns);

        // Act
        var result1 = await _sut.GetRelatedPatternsAsync(slug);
        var result2 = await _sut.GetRelatedPatternsAsync(slug);

        // Assert
        result1.Should().BeEquivalentTo(patterns);
        result2.Should().BeEquivalentTo(patterns);
        _patternRepositoryMock.Verify(r => r.GetRelatedPatternsAsync(slug, It.IsAny<int>(), It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task GetRelatedPatternsAsync_ShouldUseDifferentCacheKeysPerSlug()
    {
        // Arrange
        var slug1 = "pattern-one";
        var slug2 = "pattern-two";
        var patterns1 = new List<Pattern> { CreateTestPattern(Guid.NewGuid()) };
        var patterns2 = new List<Pattern> { CreateTestPattern(Guid.NewGuid()) };

        _patternRepositoryMock
            .Setup(r => r.GetRelatedPatternsAsync(slug1, It.IsAny<int>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(patterns1);
        _patternRepositoryMock
            .Setup(r => r.GetRelatedPatternsAsync(slug2, It.IsAny<int>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(patterns2);

        // Act
        var result1 = await _sut.GetRelatedPatternsAsync(slug1);
        var result2 = await _sut.GetRelatedPatternsAsync(slug2);

        // Assert
        result1.Should().BeEquivalentTo(patterns1);
        result2.Should().BeEquivalentTo(patterns2);
        _patternRepositoryMock.Verify(r => r.GetRelatedPatternsAsync(slug1, It.IsAny<int>(), It.IsAny<CancellationToken>()), Times.Once);
        _patternRepositoryMock.Verify(r => r.GetRelatedPatternsAsync(slug2, It.IsAny<int>(), It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task GetRelatedPatternsAsync_ShouldReturnEmptyListWhenCacheReturnsNull()
    {
        // Arrange
        var slug = "test-pattern";
        _patternRepositoryMock
            .Setup(r => r.GetRelatedPatternsAsync(slug, It.IsAny<int>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((List<Pattern>)null!);

        // Act
        var result = await _sut.GetRelatedPatternsAsync(slug);

        // Assert
        result.Should().BeEmpty();
    }

    #endregion

    #region CreatePatternAsync Tests

    [Fact]
    public async Task CreatePatternAsync_ShouldSetAllRequiredFields()
    {
        // Arrange
        var pattern = new Pattern
        {
            Title = "Test Pattern",
            ShortDescription = "Test Description",
            Category = PatternCategory.Architecture,
            Author = "Test Author"
        };
        var tagNames = new List<string> { "tag1", "tag2" };
        var existingTags = new List<Tag>
        {
            new() { Id = Guid.NewGuid(), Name = "tag1" },
            new() { Id = Guid.NewGuid(), Name = "tag2" }
        };

        _tagRepositoryMock
            .Setup(r => r.GetByNamesAsync(tagNames, default))
            .ReturnsAsync(existingTags);
        _patternRepositoryMock
            .Setup(r => r.AddAsync(It.IsAny<Pattern>(), default))
            .ReturnsAsync((Pattern p, CancellationToken _) => p);

        // Act
        var result = await _sut.CreatePatternAsync(pattern, tagNames);

        // Assert
        result.Id.Should().NotBe(Guid.Empty);
        result.Slug.Should().Be("test-pattern");
        result.CreatedDate.Should().Be(new DateTime(2024, 1, 15, 10, 0, 0, DateTimeKind.Utc));
        result.UpdatedDate.Should().Be(new DateTime(2024, 1, 15, 10, 0, 0, DateTimeKind.Utc));
        result.Status.Should().Be(PatternStatus.Published);
        result.VoteCount.Should().Be(0);
        result.Tags.Should().HaveCount(2);
        _unitOfWorkMock.Verify(u => u.SaveChangesAsync(default), Times.Once);
    }

    [Fact]
    public async Task CreatePatternAsync_ShouldCreateNewTagsWhenNotExist()
    {
        // Arrange
        var pattern = new Pattern
        {
            Title = "Test Pattern",
            ShortDescription = "Test Description",
            Category = PatternCategory.Architecture
        };
        var tagNames = new List<string> { "existing", "new" };
        var existingTag = new Tag { Id = Guid.NewGuid(), Name = "existing" };
        var newTag = new Tag { Id = Guid.NewGuid(), Name = "new" };

        _tagRepositoryMock
            .Setup(r => r.GetByNamesAsync(tagNames, default))
            .ReturnsAsync(new List<Tag> { existingTag });
        _tagRepositoryMock
            .Setup(r => r.AddAsync(It.Is<Tag>(t => t.Name == "new"), default))
            .ReturnsAsync(newTag);
        _patternRepositoryMock
            .Setup(r => r.AddAsync(It.IsAny<Pattern>(), default))
            .ReturnsAsync((Pattern p, CancellationToken _) => p);

        // Act
        var result = await _sut.CreatePatternAsync(pattern, tagNames);

        // Assert
        result.Tags.Should().HaveCount(2);
        result.Tags.Should().Contain(t => t.Name == "existing");
        result.Tags.Should().Contain(t => t.Name == "new");
        _tagRepositoryMock.Verify(r => r.AddAsync(It.Is<Tag>(t => t.Name == "new"), default), Times.Once);
    }

    [Fact]
    public async Task CreatePatternAsync_ShouldHandleEmptyTagList()
    {
        // Arrange
        var pattern = new Pattern
        {
            Title = "Test Pattern",
            ShortDescription = "Test Description",
            Category = PatternCategory.Architecture
        };
        var tagNames = new List<string>();

        _patternRepositoryMock
            .Setup(r => r.AddAsync(It.IsAny<Pattern>(), default))
            .ReturnsAsync((Pattern p, CancellationToken _) => p);

        // Act
        var result = await _sut.CreatePatternAsync(pattern, tagNames);

        // Assert
        result.Tags.Should().BeEmpty();
        _tagRepositoryMock.Verify(r => r.GetByNamesAsync(It.IsAny<List<string>>(), default), Times.Never);
    }

    #endregion

    #region UpdatePatternAsync Tests

    [Fact]
    public async Task UpdatePatternAsync_ShouldUpdateAllFields()
    {
        // Arrange
        var id = Guid.NewGuid();
        var existing = CreateTestPattern(id);
        var updated = new Pattern
        {
            Title = "Updated Title",
            ShortDescription = "Updated Description",
            FullContent = "Updated Content",
            Category = PatternCategory.Security,
            Author = "Updated Author",
            IsFeatured = true,
            IsTrending = true
        };
        var tagNames = new List<string> { "tag1" };
        var tags = new List<Tag> { new() { Id = Guid.NewGuid(), Name = "tag1" } };

        _patternRepositoryMock
            .Setup(r => r.GetByIdAsync(id, default))
            .ReturnsAsync(existing);
        _tagRepositoryMock
            .Setup(r => r.GetByNamesAsync(tagNames, default))
            .ReturnsAsync(tags);

        // Act
        var result = await _sut.UpdatePatternAsync(id, updated, tagNames);

        // Assert
        result.Should().NotBeNull();
        result!.Title.Should().Be("Updated Title");
        result.Slug.Should().Be("updated-title");
        result.ShortDescription.Should().Be("Updated Description");
        result.FullContent.Should().Be("Updated Content");
        result.Category.Should().Be(PatternCategory.Security);
        result.Author.Should().Be("Updated Author");
        result.IsFeatured.Should().BeTrue();
        result.IsTrending.Should().BeTrue();
        result.UpdatedDate.Should().Be(new DateTime(2024, 1, 15, 10, 0, 0, DateTimeKind.Utc));
        result.Tags.Should().HaveCount(1);
        _patternRepositoryMock.Verify(r => r.UpdateAsync(existing, default), Times.Once);
        _unitOfWorkMock.Verify(u => u.SaveChangesAsync(default), Times.Once);
    }

    [Fact]
    public async Task UpdatePatternAsync_ShouldReturnNullWhenNotFound()
    {
        // Arrange
        var id = Guid.NewGuid();
        _patternRepositoryMock
            .Setup(r => r.GetByIdAsync(id, default))
            .ReturnsAsync((Pattern?)null);

        // Act
        var result = await _sut.UpdatePatternAsync(id, new Pattern(), new List<string>());

        // Assert
        result.Should().BeNull();
        _patternRepositoryMock.Verify(r => r.UpdateAsync(It.IsAny<Pattern>(), default), Times.Never);
        _unitOfWorkMock.Verify(u => u.SaveChangesAsync(default), Times.Never);
    }

    #endregion

    #region DeletePatternAsync Tests

    [Fact]
    public async Task DeletePatternAsync_ShouldDeleteAndSave()
    {
        // Arrange
        var id = Guid.NewGuid();
        _patternRepositoryMock
            .Setup(r => r.DeleteAsync(id, default))
            .ReturnsAsync(true);

        // Act
        var result = await _sut.DeletePatternAsync(id);

        // Assert
        result.Should().BeTrue();
        _patternRepositoryMock.Verify(r => r.DeleteAsync(id, default), Times.Once);
        _unitOfWorkMock.Verify(u => u.SaveChangesAsync(default), Times.Once);
    }

    [Fact]
    public async Task DeletePatternAsync_ShouldNotSaveWhenNotFound()
    {
        // Arrange
        var id = Guid.NewGuid();
        _patternRepositoryMock
            .Setup(r => r.DeleteAsync(id, default))
            .ReturnsAsync(false);

        // Act
        var result = await _sut.DeletePatternAsync(id);

        // Assert
        result.Should().BeFalse();
        _unitOfWorkMock.Verify(u => u.SaveChangesAsync(default), Times.Never);
    }

    #endregion

    #region VoteForPatternAsync Tests

    [Fact]
    public async Task VoteForPatternAsync_ShouldIncrementVoteAndInvalidateCache()
    {
        // Arrange
        var id = Guid.NewGuid();
        _patternRepositoryMock
            .Setup(r => r.IncrementVoteCountAsync(id, default))
            .ReturnsAsync(42);

        // Seed cache
        var patterns = new List<Pattern> { CreateTestPattern() };
        _patternRepositoryMock
            .Setup(r => r.GetFeaturedPatternsAsync(default))
            .ReturnsAsync(patterns);
        _patternRepositoryMock
            .Setup(r => r.GetTrendingPatternsAsync(default))
            .ReturnsAsync(patterns);
        await _sut.GetFeaturedPatternsAsync();
        await _sut.GetTrendingPatternsAsync();

        // Act
        var result = await _sut.VoteForPatternAsync(id);

        // Assert
        result.Should().Be(42);
        _patternRepositoryMock.Verify(r => r.IncrementVoteCountAsync(id, default), Times.Once);

        // Verify cache was invalidated by checking repository is called again
        _patternRepositoryMock.Invocations.Clear();
        _patternRepositoryMock
            .Setup(r => r.GetFeaturedPatternsAsync(default))
            .ReturnsAsync(patterns);
        await _sut.GetFeaturedPatternsAsync();
        _patternRepositoryMock.Verify(r => r.GetFeaturedPatternsAsync(default), Times.Once);
    }

    #endregion

    #region Helper Methods

    private Pattern CreateTestPattern(Guid? id = null)
    {
        return new Pattern
        {
            Id = id ?? Guid.NewGuid(),
            Title = "Test Pattern",
            Slug = "test-pattern",
            ShortDescription = "Test Description",
            FullContent = "Test Content",
            Category = PatternCategory.Architecture,
            Tags = new List<Tag>(),
            Author = "Test Author",
            CreatedDate = DateTime.UtcNow,
            UpdatedDate = DateTime.UtcNow,
            VoteCount = 0,
            Status = PatternStatus.Published,
            IsFeatured = false,
            IsTrending = false
        };
    }

    #endregion
}

/// <summary>
/// Fake TimeProvider for testing time-dependent logic
/// </summary>
public class FakeTimeProvider : TimeProvider
{
    private readonly DateTimeOffset _fixedTime;

    public FakeTimeProvider(DateTimeOffset fixedTime)
    {
        _fixedTime = fixedTime;
    }

    public override DateTimeOffset GetUtcNow() => _fixedTime;
}
