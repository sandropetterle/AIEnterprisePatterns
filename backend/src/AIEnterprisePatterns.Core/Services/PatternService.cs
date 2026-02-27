using AIEnterprisePatterns.Core.Entities;
using AIEnterprisePatterns.Core.Enums;
using AIEnterprisePatterns.Core.Interfaces;
using AIEnterprisePatterns.Core.ValueObjects;
using Microsoft.Extensions.Caching.Memory;

namespace AIEnterprisePatterns.Core.Services;

public class PatternService : IPatternService
{
    private readonly IPatternRepository _patternRepository;
    private readonly ITagRepository _tagRepository;
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMemoryCache _cache;
    private readonly TimeProvider _timeProvider;

    private static readonly TimeSpan CacheDuration = TimeSpan.FromMinutes(5);

    public PatternService(
        IPatternRepository patternRepository,
        ITagRepository tagRepository,
        IUnitOfWork unitOfWork,
        IMemoryCache cache,
        TimeProvider timeProvider)
    {
        _patternRepository = patternRepository;
        _tagRepository = tagRepository;
        _unitOfWork = unitOfWork;
        _cache = cache;
        _timeProvider = timeProvider;
    }

    public Task<PaginatedResult<Pattern>> GetPatternsAsync(
        int page, int pageSize, string? sortBy, string? category,
        List<string>? tags, string? search,
        DateTime? dateFrom = null, DateTime? dateTo = null,
        string? tagMode = "any", CancellationToken ct = default)
    {
        return _patternRepository.GetPatternsAsync(page, pageSize, sortBy, category, tags, search, dateFrom, dateTo, tagMode, ct);
    }

    public Task<Pattern?> GetBySlugAsync(string slug, CancellationToken ct = default)
    {
        return _patternRepository.GetBySlugAsync(slug, ct);
    }

    public async Task<List<Pattern>> GetFeaturedPatternsAsync(CancellationToken ct = default)
    {
        return await _cache.GetOrCreateAsync("featured_patterns", async entry =>
        {
            entry.AbsoluteExpirationRelativeToNow = CacheDuration;
            return await _patternRepository.GetFeaturedPatternsAsync(ct);
        }) ?? [];
    }

    public async Task<List<Pattern>> GetTrendingPatternsAsync(CancellationToken ct = default)
    {
        return await _cache.GetOrCreateAsync("trending_patterns", async entry =>
        {
            entry.AbsoluteExpirationRelativeToNow = CacheDuration;
            return await _patternRepository.GetTrendingPatternsAsync(ct);
        }) ?? [];
    }

    public async Task<List<Pattern>> GetRelatedPatternsAsync(string slug, int limit = 3, CancellationToken ct = default)
    {
        var cacheKey = $"related_patterns_{slug}";
        return await _cache.GetOrCreateAsync(cacheKey, async entry =>
        {
            entry.AbsoluteExpirationRelativeToNow = CacheDuration;
            return await _patternRepository.GetRelatedPatternsAsync(slug, limit, ct);
        }) ?? [];
    }

    public async Task<Pattern> CreatePatternAsync(Pattern pattern, List<string> tagNames, CancellationToken ct = default)
    {
        var now = _timeProvider.GetUtcNow().UtcDateTime;
        pattern.Id = Guid.NewGuid();
        pattern.Slug = Slug.FromTitle(pattern.Title);
        pattern.CreatedDate = now;
        pattern.UpdatedDate = now;
        pattern.Status = PatternStatus.Published;
        pattern.VoteCount = 0;

        pattern.Tags = await ResolveTagsAsync(tagNames, ct);

        var created = await _patternRepository.AddAsync(pattern, ct);
        await _unitOfWork.SaveChangesAsync(ct);
        return created;
    }

    public async Task<Pattern?> UpdatePatternAsync(Guid id, Pattern updated, List<string> tagNames, CancellationToken ct = default)
    {
        var existing = await _patternRepository.GetByIdAsync(id, ct);
        if (existing == null) return null;

        existing.Title = updated.Title;
        existing.Slug = Slug.FromTitle(updated.Title);
        existing.ShortDescription = updated.ShortDescription;
        existing.FullContent = updated.FullContent;
        existing.Category = updated.Category;
        existing.Author = updated.Author;
        existing.IsFeatured = updated.IsFeatured;
        existing.IsTrending = updated.IsTrending;
        existing.UpdatedDate = _timeProvider.GetUtcNow().UtcDateTime;

        existing.Tags = await ResolveTagsAsync(tagNames, ct);

        await _patternRepository.UpdateAsync(existing, ct);
        await _unitOfWork.SaveChangesAsync(ct);
        return existing;
    }

    public async Task<bool> DeletePatternAsync(Guid id, CancellationToken ct = default)
    {
        var result = await _patternRepository.DeleteAsync(id, ct);
        if (result)
            await _unitOfWork.SaveChangesAsync(ct);
        return result;
    }

    public async Task<int> VoteForPatternAsync(Guid id, CancellationToken ct = default)
    {
        var result = await _patternRepository.IncrementVoteCountAsync(id, ct);
        _cache.Remove("featured_patterns");
        _cache.Remove("trending_patterns");
        return result;
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
}
