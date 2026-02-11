using AIEnterprisePatterns.Api.DTOs;
using AIEnterprisePatterns.Core.Entities;

namespace AIEnterprisePatterns.Api.Mappers;

public static class PatternMapper
{
    public static PatternListDto ToListDto(Pattern p) => new()
    {
        Id = p.Id,
        Title = p.Title,
        Slug = p.Slug,
        ShortDescription = p.ShortDescription,
        Category = p.Category.ToString(),
        Tags = p.Tags.Select(t => t.Name).ToList(),
        Author = p.Author,
        CreatedDate = p.CreatedDate.ToString("o"),
        UpdatedDate = p.UpdatedDate.ToString("o"),
        VoteCount = p.VoteCount,
        Status = p.Status.ToString().ToLower(),
        IsFeatured = p.IsFeatured,
        IsTrending = p.IsTrending
    };

    public static PatternDetailDto ToDetailDto(Pattern p) => new()
    {
        Id = p.Id,
        Title = p.Title,
        Slug = p.Slug,
        ShortDescription = p.ShortDescription,
        FullContent = p.FullContent,
        Category = p.Category.ToString(),
        Tags = p.Tags.Select(t => t.Name).ToList(),
        Author = p.Author,
        CreatedDate = p.CreatedDate.ToString("o"),
        UpdatedDate = p.UpdatedDate.ToString("o"),
        VoteCount = p.VoteCount,
        Status = p.Status.ToString().ToLower(),
        IsFeatured = p.IsFeatured,
        IsTrending = p.IsTrending
    };
}
