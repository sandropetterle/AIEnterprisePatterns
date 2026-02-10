using System.Text.RegularExpressions;
using AIEnterprisePatterns.Core.Entities;
using AIEnterprisePatterns.Core.Enums;
using AIEnterprisePatterns.Core.Interfaces;

namespace AIEnterprisePatterns.Core.Services;

public partial class PatternService : IPatternService
{
    private readonly IPatternRepository _patternRepository;
    private readonly ITagRepository _tagRepository;

    public PatternService(IPatternRepository patternRepository, ITagRepository tagRepository)
    {
        _patternRepository = patternRepository;
        _tagRepository = tagRepository;
    }

    public Task<PaginatedResult<Pattern>> GetPatternsAsync(
        int page, int pageSize, string? sortBy, string? category,
        List<string>? tags, string? search, CancellationToken ct = default)
    {
        return _patternRepository.GetPatternsAsync(page, pageSize, sortBy, category, tags, search, ct);
    }

    public Task<Pattern?> GetBySlugAsync(string slug, CancellationToken ct = default)
    {
        return _patternRepository.GetBySlugAsync(slug, ct);
    }

    public Task<List<Pattern>> GetFeaturedPatternsAsync(CancellationToken ct = default)
    {
        return _patternRepository.GetFeaturedPatternsAsync(ct);
    }

    public Task<List<Pattern>> GetTrendingPatternsAsync(CancellationToken ct = default)
    {
        return _patternRepository.GetTrendingPatternsAsync(ct);
    }

    public async Task<Pattern> CreatePatternAsync(Pattern pattern, List<string> tagNames, CancellationToken ct = default)
    {
        pattern.Id = Guid.NewGuid();
        pattern.Slug = GenerateSlug(pattern.Title);
        pattern.CreatedDate = DateTime.UtcNow;
        pattern.UpdatedDate = DateTime.UtcNow;
        pattern.Status = PatternStatus.Published;
        pattern.VoteCount = 0;

        // Resolve tags
        pattern.Tags = await ResolveTagsAsync(tagNames, ct);

        return await _patternRepository.AddAsync(pattern, ct);
    }

    public async Task<Pattern?> UpdatePatternAsync(Guid id, Pattern updated, List<string> tagNames, CancellationToken ct = default)
    {
        var existing = await _patternRepository.GetByIdAsync(id, ct);
        if (existing == null) return null;

        existing.Title = updated.Title;
        existing.Slug = GenerateSlug(updated.Title);
        existing.ShortDescription = updated.ShortDescription;
        existing.FullContent = updated.FullContent;
        existing.Category = updated.Category;
        existing.Author = updated.Author;
        existing.IsFeatured = updated.IsFeatured;
        existing.IsTrending = updated.IsTrending;
        existing.UpdatedDate = DateTime.UtcNow;

        // Resolve tags
        existing.Tags = await ResolveTagsAsync(tagNames, ct);

        await _patternRepository.UpdateAsync(existing, ct);
        return existing;
    }

    public Task<bool> DeletePatternAsync(Guid id, CancellationToken ct = default)
    {
        return _patternRepository.DeleteAsync(id, ct);
    }

    public Task<int> VoteForPatternAsync(Guid id, CancellationToken ct = default)
    {
        return _patternRepository.IncrementVoteCountAsync(id, ct);
    }

    private async Task<List<Tag>> ResolveTagsAsync(List<string> tagNames, CancellationToken ct)
    {
        if (tagNames.Count == 0) return new List<Tag>();

        var existingTags = await _tagRepository.GetByNamesAsync(tagNames, ct);
        var existingNames = existingTags.Select(t => t.Name).ToHashSet(StringComparer.OrdinalIgnoreCase);

        foreach (var name in tagNames.Where(n => !existingNames.Contains(n)))
        {
            var newTag = await _tagRepository.AddAsync(new Tag { Id = Guid.NewGuid(), Name = name }, ct);
            existingTags.Add(newTag);
        }

        return existingTags;
    }

    private static string GenerateSlug(string title)
    {
        var slug = title.ToLowerInvariant();
        slug = SlugInvalidChars().Replace(slug, "");
        slug = SlugWhitespace().Replace(slug, "-");
        slug = SlugMultipleDashes().Replace(slug, "-");
        return slug.Trim('-');
    }

    [GeneratedRegex(@"[^a-z0-9\s-]")]
    private static partial Regex SlugInvalidChars();

    [GeneratedRegex(@"\s+")]
    private static partial Regex SlugWhitespace();

    [GeneratedRegex(@"-+")]
    private static partial Regex SlugMultipleDashes();
}
