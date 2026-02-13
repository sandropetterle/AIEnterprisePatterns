using AIEnterprisePatterns.Api.Mappers;
using AIEnterprisePatterns.Core.Entities;
using AIEnterprisePatterns.Core.Enums;
using FluentAssertions;

namespace AIEnterprisePatterns.Api.Tests.Mappers;

public class PatternMapperTests
{
    #region ToListDto Tests

    [Fact]
    public void ToListDto_ShouldMapAllProperties()
    {
        // Arrange
        var pattern = CreateTestPattern();

        // Act
        var result = PatternMapper.ToListDto(pattern);

        // Assert
        result.Id.Should().Be(pattern.Id);
        result.Title.Should().Be(pattern.Title);
        result.Slug.Should().Be(pattern.Slug);
        result.ShortDescription.Should().Be(pattern.ShortDescription);
        result.Author.Should().Be(pattern.Author);
        result.VoteCount.Should().Be(pattern.VoteCount);
        result.IsFeatured.Should().Be(pattern.IsFeatured);
        result.IsTrending.Should().Be(pattern.IsTrending);
    }

    [Theory]
    [InlineData(PatternCategory.Architecture, "Architecture")]
    [InlineData(PatternCategory.DesignPatterns, "DesignPatterns")]
    [InlineData(PatternCategory.AIPrompts, "AIPrompts")]
    [InlineData(PatternCategory.BestPractices, "BestPractices")]
    [InlineData(PatternCategory.CodeGeneration, "CodeGeneration")]
    [InlineData(PatternCategory.Testing, "Testing")]
    [InlineData(PatternCategory.Security, "Security")]
    [InlineData(PatternCategory.Performance, "Performance")]
    public void ToListDto_ShouldMapCategoryCorrectly(PatternCategory category, string expectedString)
    {
        // Arrange
        var pattern = CreateTestPattern();
        pattern.Category = category;

        // Act
        var result = PatternMapper.ToListDto(pattern);

        // Assert
        result.Category.Should().Be(expectedString);
    }

    [Fact]
    public void ToListDto_ShouldMapTagsToNames()
    {
        // Arrange
        var pattern = CreateTestPattern();
        pattern.Tags = new List<Tag>
        {
            new() { Id = Guid.NewGuid(), Name = "Tag1" },
            new() { Id = Guid.NewGuid(), Name = "Tag2" },
            new() { Id = Guid.NewGuid(), Name = "Tag3" }
        };

        // Act
        var result = PatternMapper.ToListDto(pattern);

        // Assert
        result.Tags.Should().HaveCount(3);
        result.Tags.Should().Contain("Tag1");
        result.Tags.Should().Contain("Tag2");
        result.Tags.Should().Contain("Tag3");
    }

    [Fact]
    public void ToListDto_ShouldFormatDatesAsISO8601()
    {
        // Arrange
        var createdDate = new DateTime(2024, 1, 15, 10, 30, 45, DateTimeKind.Utc);
        var updatedDate = new DateTime(2024, 1, 20, 14, 15, 30, DateTimeKind.Utc);
        var pattern = CreateTestPattern();
        pattern.CreatedDate = createdDate;
        pattern.UpdatedDate = updatedDate;

        // Act
        var result = PatternMapper.ToListDto(pattern);

        // Assert
        result.CreatedDate.Should().Be("2024-01-15T10:30:45.0000000Z");
        result.UpdatedDate.Should().Be("2024-01-20T14:15:30.0000000Z");
    }

    [Theory]
    [InlineData(PatternStatus.Draft, "draft")]
    [InlineData(PatternStatus.Published, "published")]
    public void ToListDto_ShouldMapStatusAsLowercase(PatternStatus status, string expectedString)
    {
        // Arrange
        var pattern = CreateTestPattern();
        pattern.Status = status;

        // Act
        var result = PatternMapper.ToListDto(pattern);

        // Assert
        result.Status.Should().Be(expectedString);
    }

    [Fact]
    public void ToListDto_ShouldHandleEmptyTags()
    {
        // Arrange
        var pattern = CreateTestPattern();
        pattern.Tags = new List<Tag>();

        // Act
        var result = PatternMapper.ToListDto(pattern);

        // Assert
        result.Tags.Should().BeEmpty();
    }

    [Fact]
    public void ToListDto_ShouldHandleNullAuthor()
    {
        // Arrange
        var pattern = CreateTestPattern();
        pattern.Author = null;

        // Act
        var result = PatternMapper.ToListDto(pattern);

        // Assert
        result.Author.Should().BeNull();
    }

    #endregion

    #region ToDetailDto Tests

    [Fact]
    public void ToDetailDto_ShouldMapAllPropertiesIncludingFullContent()
    {
        // Arrange
        var pattern = CreateTestPattern();

        // Act
        var result = PatternMapper.ToDetailDto(pattern);

        // Assert
        result.Id.Should().Be(pattern.Id);
        result.Title.Should().Be(pattern.Title);
        result.Slug.Should().Be(pattern.Slug);
        result.ShortDescription.Should().Be(pattern.ShortDescription);
        result.FullContent.Should().Be(pattern.FullContent);
        result.Author.Should().Be(pattern.Author);
        result.VoteCount.Should().Be(pattern.VoteCount);
        result.IsFeatured.Should().Be(pattern.IsFeatured);
        result.IsTrending.Should().Be(pattern.IsTrending);
    }

    [Theory]
    [InlineData(PatternCategory.Architecture, "Architecture")]
    [InlineData(PatternCategory.DesignPatterns, "DesignPatterns")]
    [InlineData(PatternCategory.Security, "Security")]
    public void ToDetailDto_ShouldMapCategoryCorrectly(PatternCategory category, string expectedString)
    {
        // Arrange
        var pattern = CreateTestPattern();
        pattern.Category = category;

        // Act
        var result = PatternMapper.ToDetailDto(pattern);

        // Assert
        result.Category.Should().Be(expectedString);
    }

    [Fact]
    public void ToDetailDto_ShouldMapTagsToNames()
    {
        // Arrange
        var pattern = CreateTestPattern();
        pattern.Tags = new List<Tag>
        {
            new() { Id = Guid.NewGuid(), Name = "Testing" },
            new() { Id = Guid.NewGuid(), Name = "Architecture" }
        };

        // Act
        var result = PatternMapper.ToDetailDto(pattern);

        // Assert
        result.Tags.Should().HaveCount(2);
        result.Tags.Should().Contain("Testing");
        result.Tags.Should().Contain("Architecture");
    }

    [Fact]
    public void ToDetailDto_ShouldFormatDatesAsISO8601()
    {
        // Arrange
        var createdDate = new DateTime(2024, 1, 15, 10, 30, 45, DateTimeKind.Utc);
        var pattern = CreateTestPattern();
        pattern.CreatedDate = createdDate;
        pattern.UpdatedDate = createdDate;

        // Act
        var result = PatternMapper.ToDetailDto(pattern);

        // Assert
        result.CreatedDate.Should().Be("2024-01-15T10:30:45.0000000Z");
        result.UpdatedDate.Should().Be("2024-01-15T10:30:45.0000000Z");
    }

    [Theory]
    [InlineData(PatternStatus.Draft, "draft")]
    [InlineData(PatternStatus.Published, "published")]
    public void ToDetailDto_ShouldMapStatusAsLowercase(PatternStatus status, string expectedString)
    {
        // Arrange
        var pattern = CreateTestPattern();
        pattern.Status = status;

        // Act
        var result = PatternMapper.ToDetailDto(pattern);

        // Assert
        result.Status.Should().Be(expectedString);
    }

    #endregion

    #region Helper Methods

    private Pattern CreateTestPattern()
    {
        return new Pattern
        {
            Id = Guid.NewGuid(),
            Title = "Test Pattern",
            Slug = "test-pattern",
            ShortDescription = "Test short description",
            FullContent = "Test full content with detailed information",
            Category = PatternCategory.Architecture,
            Tags = new List<Tag>(),
            Author = "Test Author",
            CreatedDate = new DateTime(2024, 1, 15, 10, 0, 0, DateTimeKind.Utc),
            UpdatedDate = new DateTime(2024, 1, 20, 14, 30, 0, DateTimeKind.Utc),
            VoteCount = 42,
            Status = PatternStatus.Published,
            IsFeatured = true,
            IsTrending = false
        };
    }

    #endregion
}
