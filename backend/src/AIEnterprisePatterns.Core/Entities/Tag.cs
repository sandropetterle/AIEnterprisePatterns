using System.ComponentModel.DataAnnotations;

namespace AIEnterprisePatterns.Core.Entities;

public class Tag : BaseEntity
{
    [Required, MaxLength(50)]
    public string Name { get; set; } = string.Empty;

    public List<Pattern> Patterns { get; set; } = new();
}
