namespace AIEnterprisePatterns.Api.DTOs;

public class PaginatedResponse<T>
{
    public List<T> Patterns { get; set; } = new();
    public int TotalCount { get; set; }
    public int CurrentPage { get; set; }
    public int PageSize { get; set; }
    public int TotalPages { get; set; }
}
