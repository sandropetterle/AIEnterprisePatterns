using AIEnterprisePatterns.Core.Entities;

namespace AIEnterprisePatterns.Core.Interfaces;

public class PaginatedResult<T>
{
    public List<T> Items { get; set; } = new();
    public int TotalCount { get; set; }
    public int CurrentPage { get; set; }
    public int PageSize { get; set; }
    public int TotalPages => (int)Math.Ceiling((double)TotalCount / PageSize);
}

public interface IPatternRepository
{
    Task<PaginatedResult<Pattern>> GetPatternsAsync(
        int page, int pageSize, string? sortBy, string? category,
        List<string>? tags, string? search,
        DateTime? dateFrom = null, DateTime? dateTo = null,
        string? tagMode = "any", CancellationToken ct = default);

    Task<Pattern?> GetBySlugAsync(string slug, CancellationToken ct = default);
    Task<Pattern?> GetByIdAsync(Guid id, CancellationToken ct = default);
    Task<List<Pattern>> GetFeaturedPatternsAsync(CancellationToken ct = default);
    Task<List<Pattern>> GetTrendingPatternsAsync(CancellationToken ct = default);
    Task<List<Pattern>> GetRelatedPatternsAsync(string slug, int limit = 3, CancellationToken ct = default);

    Task<Pattern> AddAsync(Pattern pattern, CancellationToken ct = default);
    Task UpdateAsync(Pattern pattern, CancellationToken ct = default);
    Task<bool> DeleteAsync(Guid id, CancellationToken ct = default);
    Task<int> IncrementVoteCountAsync(Guid id, CancellationToken ct = default);
}
