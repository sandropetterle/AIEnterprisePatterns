using AIEnterprisePatterns.Core.Entities;
using AIEnterprisePatterns.Core.Enums;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace AIEnterprisePatterns.Data.Configurations;

public class PatternConfiguration : IEntityTypeConfiguration<Pattern>
{
    public void Configure(EntityTypeBuilder<Pattern> builder)
    {
        builder.HasKey(p => p.Id);

        builder.Property(p => p.Title).IsRequired().HasMaxLength(255);
        builder.Property(p => p.Slug).IsRequired().HasMaxLength(255);
        builder.Property(p => p.ShortDescription).IsRequired();
        builder.Property(p => p.Author).HasMaxLength(100);

        // Enum stored as string to match frontend expectations
        builder.Property(p => p.Category)
            .HasConversion<string>()
            .HasMaxLength(50)
            .IsRequired();

        builder.Property(p => p.Status)
            .HasConversion<string>()
            .HasMaxLength(20)
            .IsRequired();

        // Indexes
        builder.HasIndex(p => p.Slug).IsUnique();
        builder.HasIndex(p => p.Category);
        builder.HasIndex(p => p.Status);
        builder.HasIndex(p => p.CreatedDate);
        builder.HasIndex(p => p.VoteCount);
        builder.HasIndex(p => p.IsFeatured);
        builder.HasIndex(p => p.IsTrending);
    }
}
