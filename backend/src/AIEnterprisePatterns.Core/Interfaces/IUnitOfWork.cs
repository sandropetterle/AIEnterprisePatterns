namespace AIEnterprisePatterns.Core.Interfaces;

public interface IUnitOfWork : IDisposable
{
    IPatternRepository Patterns { get; }
    ITagRepository Tags { get; }
    Task<int> SaveChangesAsync(CancellationToken ct = default);
}
