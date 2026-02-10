using AIEnterprisePatterns.Core.Entities;
using Microsoft.EntityFrameworkCore;

namespace AIEnterprisePatterns.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public DbSet<Pattern> Patterns => Set<Pattern>();
    public DbSet<Tag> Tags => Set<Tag>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);
        SeedData(modelBuilder);
    }

    private static void SeedData(ModelBuilder modelBuilder)
    {
        // Tags
        var tagCleanArchitecture = new { Id = Guid.Parse("a0000000-0000-0000-0000-000000000001"), Name = "Clean Architecture" };
        var tagRefactoring = new { Id = Guid.Parse("a0000000-0000-0000-0000-000000000002"), Name = "Refactoring" };
        var tagAiAssisted = new { Id = Guid.Parse("a0000000-0000-0000-0000-000000000003"), Name = "AI-Assisted" };
        var tagRepository = new { Id = Guid.Parse("a0000000-0000-0000-0000-000000000004"), Name = "Repository" };
        var tagEfCore = new { Id = Guid.Parse("a0000000-0000-0000-0000-000000000005"), Name = "EF Core" };
        var tagTesting = new { Id = Guid.Parse("a0000000-0000-0000-0000-000000000006"), Name = "Testing" };
        var tagCodeReview = new { Id = Guid.Parse("a0000000-0000-0000-0000-000000000007"), Name = "Code Review" };
        var tagPrompts = new { Id = Guid.Parse("a0000000-0000-0000-0000-000000000008"), Name = "Prompts" };
        var tagSolid = new { Id = Guid.Parse("a0000000-0000-0000-0000-000000000009"), Name = "SOLID" };
        var tagCqrs = new { Id = Guid.Parse("a0000000-0000-0000-0000-00000000000a"), Name = "CQRS" };
        var tagMediatR = new { Id = Guid.Parse("a0000000-0000-0000-0000-00000000000b"), Name = "MediatR" };
        var tagEventSourcing = new { Id = Guid.Parse("a0000000-0000-0000-0000-00000000000c"), Name = "Event Sourcing" };
        var tagMicroservices = new { Id = Guid.Parse("a0000000-0000-0000-0000-00000000000d"), Name = "Microservices" };
        var tagSecurity = new { Id = Guid.Parse("a0000000-0000-0000-0000-00000000000e"), Name = "Security" };
        var tagApiGateway = new { Id = Guid.Parse("a0000000-0000-0000-0000-00000000000f"), Name = "API Gateway" };
        var tagPerformance = new { Id = Guid.Parse("a0000000-0000-0000-0000-000000000010"), Name = "Performance" };
        var tagOptimization = new { Id = Guid.Parse("a0000000-0000-0000-0000-000000000011"), Name = "Optimization" };
        var tagAiTools = new { Id = Guid.Parse("a0000000-0000-0000-0000-000000000012"), Name = "AI Tools" };

        modelBuilder.Entity<Tag>().HasData(
            tagCleanArchitecture, tagRefactoring, tagAiAssisted, tagRepository,
            tagEfCore, tagTesting, tagCodeReview, tagPrompts, tagSolid,
            tagCqrs, tagMediatR, tagEventSourcing, tagMicroservices,
            tagSecurity, tagApiGateway, tagPerformance, tagOptimization, tagAiTools
        );

        // Patterns (without Tags navigation - seeded via junction table)
        var pattern1Id = Guid.Parse("b0000000-0000-0000-0000-000000000001");
        var pattern2Id = Guid.Parse("b0000000-0000-0000-0000-000000000002");
        var pattern3Id = Guid.Parse("b0000000-0000-0000-0000-000000000003");
        var pattern4Id = Guid.Parse("b0000000-0000-0000-0000-000000000004");
        var pattern5Id = Guid.Parse("b0000000-0000-0000-0000-000000000005");
        var pattern6Id = Guid.Parse("b0000000-0000-0000-0000-000000000006");

        modelBuilder.Entity<Pattern>().HasData(
            new
            {
                Id = pattern1Id,
                Title = "Clean Architecture with AI-Assisted Refactoring",
                Slug = "clean-architecture-ai-refactoring",
                ShortDescription = "Learn how to leverage AI tools to refactor legacy code into clean architecture patterns, including layered separation and dependency injection.",
                FullContent = SeedContent.Pattern1FullContent,
                Category = Core.Enums.PatternCategory.Architecture,
                Author = "John Doe",
                CreatedDate = new DateTime(2024, 1, 15, 10, 0, 0, DateTimeKind.Utc),
                UpdatedDate = new DateTime(2024, 1, 20, 14, 30, 0, DateTimeKind.Utc),
                VoteCount = 42,
                Status = Core.Enums.PatternStatus.Published,
                IsFeatured = true,
                IsTrending = false
            },
            new
            {
                Id = pattern2Id,
                Title = "Repository Pattern with Entity Framework Core",
                Slug = "repository-pattern-ef-core",
                ShortDescription = "Implement the Repository pattern using EF Core with best practices for unit testing, async operations, and generic repositories.",
                FullContent = SeedContent.Pattern2FullContent,
                Category = Core.Enums.PatternCategory.DesignPatterns,
                Author = "Jane Smith",
                CreatedDate = new DateTime(2024, 1, 18, 9, 0, 0, DateTimeKind.Utc),
                UpdatedDate = new DateTime(2024, 1, 18, 9, 0, 0, DateTimeKind.Utc),
                VoteCount = 38,
                Status = Core.Enums.PatternStatus.Published,
                IsFeatured = false,
                IsTrending = true
            },
            new
            {
                Id = pattern3Id,
                Title = "AI Prompt Engineering for Code Review",
                Slug = "ai-prompt-code-review",
                ShortDescription = "Curated prompts for AI-assisted code reviews covering SOLID principles, security vulnerabilities, and performance optimization.",
                FullContent = SeedContent.Pattern3FullContent,
                Category = Core.Enums.PatternCategory.AIPrompts,
                Author = "Alice Johnson",
                CreatedDate = new DateTime(2024, 1, 22, 11, 0, 0, DateTimeKind.Utc),
                UpdatedDate = new DateTime(2024, 1, 25, 16, 45, 0, DateTimeKind.Utc),
                VoteCount = 56,
                Status = Core.Enums.PatternStatus.Published,
                IsFeatured = true,
                IsTrending = true
            },
            new
            {
                Id = pattern4Id,
                Title = "CQRS Pattern Implementation Guide",
                Slug = "cqrs-pattern-implementation",
                ShortDescription = "Complete guide to implementing Command Query Responsibility Segregation in .NET applications with MediatR and event sourcing.",
                FullContent = SeedContent.Pattern4FullContent,
                Category = Core.Enums.PatternCategory.Architecture,
                Author = "Bob Williams",
                CreatedDate = new DateTime(2024, 1, 10, 8, 0, 0, DateTimeKind.Utc),
                UpdatedDate = new DateTime(2024, 1, 10, 8, 0, 0, DateTimeKind.Utc),
                VoteCount = 34,
                Status = Core.Enums.PatternStatus.Published,
                IsFeatured = true,
                IsTrending = false
            },
            new
            {
                Id = pattern5Id,
                Title = "Microservices Security Best Practices",
                Slug = "microservices-security-practices",
                ShortDescription = "Essential security patterns for microservices including service-to-service authentication, API gateway security, and secret management.",
                FullContent = SeedContent.Pattern5FullContent,
                Category = Core.Enums.PatternCategory.Security,
                Author = "Carol Davis",
                CreatedDate = new DateTime(2024, 1, 12, 13, 0, 0, DateTimeKind.Utc),
                UpdatedDate = new DateTime(2024, 1, 16, 10, 20, 0, DateTimeKind.Utc),
                VoteCount = 29,
                Status = Core.Enums.PatternStatus.Published,
                IsFeatured = false,
                IsTrending = true
            },
            new
            {
                Id = pattern6Id,
                Title = "Performance Optimization with AI Analysis",
                Slug = "performance-optimization-ai",
                ShortDescription = "Use AI tools to identify performance bottlenecks, optimize database queries, and improve application response times.",
                FullContent = SeedContent.Pattern6FullContent,
                Category = Core.Enums.PatternCategory.Performance,
                Author = "David Lee",
                CreatedDate = new DateTime(2024, 1, 20, 15, 0, 0, DateTimeKind.Utc),
                UpdatedDate = new DateTime(2024, 1, 20, 15, 0, 0, DateTimeKind.Utc),
                VoteCount = 23,
                Status = Core.Enums.PatternStatus.Published,
                IsFeatured = false,
                IsTrending = false
            }
        );

        // PatternTag junction table seed data
        modelBuilder.Entity<Pattern>()
            .HasMany(p => p.Tags)
            .WithMany(t => t.Patterns)
            .UsingEntity(j => j.HasData(
                // Pattern 1: Clean Architecture, Refactoring, AI-Assisted
                new { PatternsId = pattern1Id, TagsId = tagCleanArchitecture.Id },
                new { PatternsId = pattern1Id, TagsId = tagRefactoring.Id },
                new { PatternsId = pattern1Id, TagsId = tagAiAssisted.Id },
                // Pattern 2: Repository, EF Core, Testing
                new { PatternsId = pattern2Id, TagsId = tagRepository.Id },
                new { PatternsId = pattern2Id, TagsId = tagEfCore.Id },
                new { PatternsId = pattern2Id, TagsId = tagTesting.Id },
                // Pattern 3: Code Review, Prompts, SOLID
                new { PatternsId = pattern3Id, TagsId = tagCodeReview.Id },
                new { PatternsId = pattern3Id, TagsId = tagPrompts.Id },
                new { PatternsId = pattern3Id, TagsId = tagSolid.Id },
                // Pattern 4: CQRS, MediatR, Event Sourcing
                new { PatternsId = pattern4Id, TagsId = tagCqrs.Id },
                new { PatternsId = pattern4Id, TagsId = tagMediatR.Id },
                new { PatternsId = pattern4Id, TagsId = tagEventSourcing.Id },
                // Pattern 5: Microservices, Security, API Gateway
                new { PatternsId = pattern5Id, TagsId = tagMicroservices.Id },
                new { PatternsId = pattern5Id, TagsId = tagSecurity.Id },
                new { PatternsId = pattern5Id, TagsId = tagApiGateway.Id },
                // Pattern 6: Performance, Optimization, AI Tools
                new { PatternsId = pattern6Id, TagsId = tagPerformance.Id },
                new { PatternsId = pattern6Id, TagsId = tagOptimization.Id },
                new { PatternsId = pattern6Id, TagsId = tagAiTools.Id }
            ));
    }
}
