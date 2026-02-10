using AIEnterprisePatterns.Core.Interfaces;

namespace AIEnterprisePatterns.Data.Repositories;

public class UnitOfWork : IUnitOfWork
{
    private readonly ApplicationDbContext _context;

    public IPatternRepository Patterns { get; }
    public ITagRepository Tags { get; }

    public UnitOfWork(
        ApplicationDbContext context,
        IPatternRepository patternRepository,
        ITagRepository tagRepository)
    {
        _context = context;
        Patterns = patternRepository;
        Tags = tagRepository;
    }

    public async Task<int> SaveChangesAsync(CancellationToken ct = default)
    {
        return await _context.SaveChangesAsync(ct);
    }

    public void Dispose()
    {
        _context.Dispose();
    }
}
