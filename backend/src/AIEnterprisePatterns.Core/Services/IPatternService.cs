using AIEnterprisePatterns.Core.Entities;
using AIEnterprisePatterns.Core.Interfaces;

namespace AIEnterprisePatterns.Core.Services;

public interface IPatternService
{
    Task<PaginatedResult<Pattern>> GetPatternsAsync(
        int page, int pageSize, string? sortBy, string? category,
        List<string>? tags, string? search,
        DateTime? dateFrom = null, DateTime? dateTo = null,
        string? tagMode = "any", CancellationToken ct = default);

    Task<Pattern?> GetBySlugAsync(string slug, CancellationToken ct = default);
    Task<List<Pattern>> GetFeaturedPatternsAsync(CancellationToken ct = default);
    Task<List<Pattern>> GetTrendingPatternsAsync(CancellationToken ct = default);
    Task<List<Pattern>> GetRelatedPatternsAsync(string slug, int limit = 3, CancellationToken ct = default);

    Task<Pattern> CreatePatternAsync(Pattern pattern, List<string> tagNames, CancellationToken ct = default);
    Task<Pattern?> UpdatePatternAsync(Guid id, Pattern updated, List<string> tagNames, CancellationToken ct = default);
    Task<bool> DeletePatternAsync(Guid id, CancellationToken ct = default);
    Task<int> VoteForPatternAsync(Guid id, CancellationToken ct = default);
}
