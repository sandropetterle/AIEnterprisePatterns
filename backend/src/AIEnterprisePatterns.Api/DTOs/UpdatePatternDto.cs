using System.ComponentModel.DataAnnotations;

namespace AIEnterprisePatterns.Api.DTOs;

public class UpdatePatternDto
{
    [Required, MaxLength(255)]
    public string Title { get; set; } = string.Empty;

    [Required]
    public string ShortDescription { get; set; } = string.Empty;

    public string? FullContent { get; set; }

    [Required]
    public string Category { get; set; } = string.Empty;

    public List<string> Tags { get; set; } = new();

    [MaxLength(100)]
    public string? Author { get; set; }

    public bool IsFeatured { get; set; }
    public bool IsTrending { get; set; }
}
