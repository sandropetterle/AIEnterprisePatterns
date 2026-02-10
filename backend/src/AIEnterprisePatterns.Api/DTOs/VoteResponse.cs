namespace AIEnterprisePatterns.Api.DTOs;

public class VoteResponse
{
    public Guid PatternId { get; set; }
    public int VoteCount { get; set; }
}
