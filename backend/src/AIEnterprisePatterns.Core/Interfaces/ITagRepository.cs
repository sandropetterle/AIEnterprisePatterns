using AIEnterprisePatterns.Core.Entities;

namespace AIEnterprisePatterns.Core.Interfaces;

public interface ITagRepository
{
    Task<List<Tag>> GetAllAsync(CancellationToken ct = default);
    Task<List<Tag>> GetByNamesAsync(List<string> names, CancellationToken ct = default);
    Task<Tag> AddAsync(Tag tag, CancellationToken ct = default);
}
