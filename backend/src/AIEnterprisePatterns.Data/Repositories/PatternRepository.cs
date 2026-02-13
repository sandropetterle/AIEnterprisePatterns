using AIEnterprisePatterns.Core.Entities;
using AIEnterprisePatterns.Core.Enums;
using AIEnterprisePatterns.Core.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace AIEnterprisePatterns.Data.Repositories;

public class PatternRepository : IPatternRepository
{
    private readonly ApplicationDbContext _context;

    public PatternRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<PaginatedResult<Pattern>> GetPatternsAsync(
        int page, int pageSize, string? sortBy, string? category,
        List<string>? tags, string? search, CancellationToken ct = default)
    {
        var query = _context.Patterns
            .Include(p => p.Tags)
            .Where(p => p.Status == PatternStatus.Published)
            .AsNoTracking();

        // Filter by category
        if (!string.IsNullOrWhiteSpace(category) &&
            Enum.TryParse<PatternCategory>(category, true, out var parsedCategory))
        {
            query = query.Where(p => p.Category == parsedCategory);
        }

        // Filter by tags
        if (tags is { Count: > 0 })
        {
            query = query.Where(p => p.Tags.Any(t => tags.Contains(t.Name)));
        }

        // Search
        if (!string.IsNullOrWhiteSpace(search))
        {
            var searchLower = search.ToLower();
            query = query.Where(p =>
                p.Title.ToLower().Contains(searchLower) ||
                p.ShortDescription.ToLower().Contains(searchLower));
        }

        // Get total count before pagination
        var totalCount = await query.CountAsync(ct);

        // Sort
        query = sortBy?.ToLower() switch
        {
            "votes" => query.OrderByDescending(p => p.VoteCount),
            "alphabetical" => query.OrderBy(p => p.Title),
            _ => query.OrderByDescending(p => p.CreatedDate)
        };

        // Paginate with projection (exclude FullContent for list views)
        var patterns = await query
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(p => new Pattern
            {
                Id = p.Id,
                Title = p.Title,
                Slug = p.Slug,
                ShortDescription = p.ShortDescription,
                Category = p.Category,
                Tags = p.Tags,
                Author = p.Author,
                CreatedDate = p.CreatedDate,
                UpdatedDate = p.UpdatedDate,
                VoteCount = p.VoteCount,
                Status = p.Status,
                IsFeatured = p.IsFeatured,
                IsTrending = p.IsTrending
            })
            .ToListAsync(ct);

        return new PaginatedResult<Pattern>
        {
            Items = patterns,
            TotalCount = totalCount,
            CurrentPage = page,
            PageSize = pageSize
        };
    }

    public async Task<Pattern?> GetBySlugAsync(string slug, CancellationToken ct = default)
    {
        return await _context.Patterns
            .Include(p => p.Tags)
            .AsNoTracking()
            .FirstOrDefaultAsync(p => p.Slug == slug && p.Status == PatternStatus.Published, ct);
    }

    public async Task<Pattern?> GetByIdAsync(Guid id, CancellationToken ct = default)
    {
        return await _context.Patterns
            .Include(p => p.Tags)
            .FirstOrDefaultAsync(p => p.Id == id, ct);
    }

    public async Task<List<Pattern>> GetFeaturedPatternsAsync(CancellationToken ct = default)
    {
        return await _context.Patterns
            .Include(p => p.Tags)
            .Where(p => p.IsFeatured && p.Status == PatternStatus.Published)
            .OrderByDescending(p => p.VoteCount)
            .AsNoTracking()
            .ToListAsync(ct);
    }

    public async Task<List<Pattern>> GetTrendingPatternsAsync(CancellationToken ct = default)
    {
        return await _context.Patterns
            .Include(p => p.Tags)
            .Where(p => p.IsTrending && p.Status == PatternStatus.Published)
            .OrderByDescending(p => p.VoteCount)
            .AsNoTracking()
            .ToListAsync(ct);
    }

    public Task<Pattern> AddAsync(Pattern pattern, CancellationToken ct = default)
    {
        _context.Patterns.Add(pattern);
        return Task.FromResult(pattern);
    }

    public Task UpdateAsync(Pattern pattern, CancellationToken ct = default)
    {
        _context.Patterns.Update(pattern);
        return Task.CompletedTask;
    }

    public async Task<bool> DeleteAsync(Guid id, CancellationToken ct = default)
    {
        var pattern = await _context.Patterns.FindAsync(new object[] { id }, ct);
        if (pattern == null) return false;

        _context.Patterns.Remove(pattern);
        return true;
    }

    public async Task<int> IncrementVoteCountAsync(Guid id, CancellationToken ct = default)
    {
        // Use traditional approach instead of ExecuteUpdateAsync for better test compatibility
        // ExecuteUpdateAsync has issues with in-memory database provider
        var pattern = await _context.Patterns.FindAsync(new object[] { id }, ct);
        if (pattern == null) return -1;

        pattern.VoteCount++;
        await _context.SaveChangesAsync(ct);
        return pattern.VoteCount;
    }
}
