using AIEnterprisePatterns.Api.DTOs;
using AIEnterprisePatterns.Core.Entities;
using AIEnterprisePatterns.Core.Enums;
using AIEnterprisePatterns.Core.Services;
using Microsoft.AspNetCore.Mvc;

namespace AIEnterprisePatterns.Api.Controllers;

[ApiController]
[Route("api/patterns")]
public class PatternsController : ControllerBase
{
    private readonly IPatternService _patternService;

    public PatternsController(IPatternService patternService)
    {
        _patternService = patternService;
    }

    [HttpGet]
    public async Task<ActionResult<PaginatedResponse<PatternListDto>>> GetPatterns(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 9,
        [FromQuery] string? sortBy = "recent",
        [FromQuery] string? category = null,
        [FromQuery] string? tags = null,
        [FromQuery] string? search = null,
        CancellationToken ct = default)
    {
        var tagList = tags?.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).ToList();

        var result = await _patternService.GetPatternsAsync(page, pageSize, sortBy, category, tagList, search, ct);

        return Ok(new PaginatedResponse<PatternListDto>
        {
            Patterns = result.Items.Select(MapToListDto).ToList(),
            TotalCount = result.TotalCount,
            CurrentPage = result.CurrentPage,
            PageSize = result.PageSize,
            TotalPages = result.TotalPages
        });
    }

    [HttpGet("featured")]
    public async Task<ActionResult<IEnumerable<PatternListDto>>> GetFeaturedPatterns(CancellationToken ct = default)
    {
        var patterns = await _patternService.GetFeaturedPatternsAsync(ct);
        return Ok(patterns.Select(MapToListDto));
    }

    [HttpGet("trending")]
    public async Task<ActionResult<IEnumerable<PatternListDto>>> GetTrendingPatterns(CancellationToken ct = default)
    {
        var patterns = await _patternService.GetTrendingPatternsAsync(ct);
        return Ok(patterns.Select(MapToListDto));
    }

    [HttpGet("{slug}")]
    public async Task<ActionResult<PatternDetailDto>> GetPatternBySlug(string slug, CancellationToken ct = default)
    {
        var pattern = await _patternService.GetBySlugAsync(slug, ct);
        if (pattern == null) return NotFound();

        return Ok(MapToDetailDto(pattern));
    }

    [HttpPost("{id:guid}/vote")]
    public async Task<ActionResult<VoteResponse>> VoteForPattern(Guid id, CancellationToken ct = default)
    {
        var newCount = await _patternService.VoteForPatternAsync(id, ct);
        if (newCount < 0) return NotFound();

        return Ok(new VoteResponse { PatternId = id, VoteCount = newCount });
    }

    [HttpPost]
    public async Task<ActionResult<PatternDetailDto>> CreatePattern(CreatePatternDto dto, CancellationToken ct = default)
    {
        if (!Enum.TryParse<PatternCategory>(dto.Category, true, out var category))
            return BadRequest($"Invalid category: {dto.Category}");

        var pattern = new Pattern
        {
            Title = dto.Title,
            ShortDescription = dto.ShortDescription,
            FullContent = dto.FullContent,
            Category = category,
            Author = dto.Author
        };

        var created = await _patternService.CreatePatternAsync(pattern, dto.Tags, ct);
        var detailDto = MapToDetailDto(created);

        return CreatedAtAction(nameof(GetPatternBySlug), new { slug = created.Slug }, detailDto);
    }

    [HttpPut("{id:guid}")]
    public async Task<ActionResult<PatternDetailDto>> UpdatePattern(Guid id, UpdatePatternDto dto, CancellationToken ct = default)
    {
        if (!Enum.TryParse<PatternCategory>(dto.Category, true, out var category))
            return BadRequest($"Invalid category: {dto.Category}");

        var updated = new Pattern
        {
            Title = dto.Title,
            ShortDescription = dto.ShortDescription,
            FullContent = dto.FullContent,
            Category = category,
            Author = dto.Author,
            IsFeatured = dto.IsFeatured,
            IsTrending = dto.IsTrending
        };

        var result = await _patternService.UpdatePatternAsync(id, updated, dto.Tags, ct);
        if (result == null) return NotFound();

        return Ok(MapToDetailDto(result));
    }

    [HttpDelete("{id:guid}")]
    public async Task<ActionResult> DeletePattern(Guid id, CancellationToken ct = default)
    {
        var deleted = await _patternService.DeletePatternAsync(id, ct);
        if (!deleted) return NotFound();

        return NoContent();
    }

    private static PatternListDto MapToListDto(Pattern p) => new()
    {
        Id = p.Id,
        Title = p.Title,
        Slug = p.Slug,
        ShortDescription = p.ShortDescription,
        Category = p.Category.ToString(),
        Tags = p.Tags.Select(t => t.Name).ToList(),
        Author = p.Author,
        CreatedDate = p.CreatedDate.ToString("o"),
        UpdatedDate = p.UpdatedDate.ToString("o"),
        VoteCount = p.VoteCount,
        Status = p.Status.ToString().ToLower(),
        IsFeatured = p.IsFeatured,
        IsTrending = p.IsTrending
    };

    private static PatternDetailDto MapToDetailDto(Pattern p) => new()
    {
        Id = p.Id,
        Title = p.Title,
        Slug = p.Slug,
        ShortDescription = p.ShortDescription,
        FullContent = p.FullContent,
        Category = p.Category.ToString(),
        Tags = p.Tags.Select(t => t.Name).ToList(),
        Author = p.Author,
        CreatedDate = p.CreatedDate.ToString("o"),
        UpdatedDate = p.UpdatedDate.ToString("o"),
        VoteCount = p.VoteCount,
        Status = p.Status.ToString().ToLower(),
        IsFeatured = p.IsFeatured,
        IsTrending = p.IsTrending
    };
}
