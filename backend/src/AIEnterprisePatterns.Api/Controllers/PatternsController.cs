using AIEnterprisePatterns.Api.DTOs;
using AIEnterprisePatterns.Api.Mappers;
using AIEnterprisePatterns.Core.Entities;
using AIEnterprisePatterns.Core.Enums;
using AIEnterprisePatterns.Core.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;

namespace AIEnterprisePatterns.Api.Controllers;

[ApiController]
[Route("api/v{version:apiVersion}/patterns")]
[Route("api/patterns")]
[Asp.Versioning.ApiVersion(1.0)]
public class PatternsController : ControllerBase
{
    private readonly IPatternService _patternService;

    public PatternsController(IPatternService patternService)
    {
        _patternService = patternService;
    }

    [HttpGet]
    public async Task<ActionResult<PaginatedResponse<PatternListDto>>> GetPatterns(
        [FromQuery] GetPatternsQuery query,
        CancellationToken ct = default)
    {
        var tagList = query.Tags?.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).ToList();

        var result = await _patternService.GetPatternsAsync(
            query.Page, query.PageSize, query.SortBy, query.Category, tagList, query.Search,
            query.DateFrom, query.DateTo, query.TagMode, ct);

        return Ok(new PaginatedResponse<PatternListDto>
        {
            Patterns = result.Items.Select(PatternMapper.ToListDto).ToList(),
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
        return Ok(patterns.Select(PatternMapper.ToListDto));
    }

    [HttpGet("trending")]
    public async Task<ActionResult<IEnumerable<PatternListDto>>> GetTrendingPatterns(CancellationToken ct = default)
    {
        var patterns = await _patternService.GetTrendingPatternsAsync(ct);
        return Ok(patterns.Select(PatternMapper.ToListDto));
    }

    [HttpGet("{slug}")]
    public async Task<ActionResult<PatternDetailDto>> GetPatternBySlug(string slug, CancellationToken ct = default)
    {
        var pattern = await _patternService.GetBySlugAsync(slug, ct);
        if (pattern == null) return NotFound();

        return Ok(PatternMapper.ToDetailDto(pattern));
    }

    [HttpGet("{slug}/related")]
    public async Task<ActionResult<IEnumerable<PatternListDto>>> GetRelatedPatterns(string slug, CancellationToken ct = default)
    {
        var patterns = await _patternService.GetRelatedPatternsAsync(slug, ct: ct);
        return Ok(patterns.Select(PatternMapper.ToListDto));
    }

    [HttpPost("{id:guid}/vote")]
    [EnableRateLimiting("vote")]
    public async Task<ActionResult<VoteResponse>> VoteForPattern(Guid id, CancellationToken ct = default)
    {
        var newCount = await _patternService.VoteForPatternAsync(id, ct);
        if (newCount < 0) return NotFound();

        return Ok(new VoteResponse { PatternId = id, VoteCount = newCount });
    }

    [Authorize(Policy = "RequireEditor")]
    [HttpPost]
    public async Task<ActionResult<PatternDetailDto>> CreatePattern(CreatePatternDto dto, CancellationToken ct = default)
    {
        var category = Enum.Parse<PatternCategory>(dto.Category, true);

        var pattern = new Pattern
        {
            Title = dto.Title,
            ShortDescription = dto.ShortDescription,
            FullContent = dto.FullContent,
            Category = category,
            Author = dto.Author
        };

        var created = await _patternService.CreatePatternAsync(pattern, dto.Tags, ct);
        var detailDto = PatternMapper.ToDetailDto(created);

        return CreatedAtAction(nameof(GetPatternBySlug), new { slug = created.Slug }, detailDto);
    }

    [Authorize(Policy = "RequireEditor")]
    [HttpPut("{id:guid}")]
    public async Task<ActionResult<PatternDetailDto>> UpdatePattern(Guid id, UpdatePatternDto dto, CancellationToken ct = default)
    {
        var category = Enum.Parse<PatternCategory>(dto.Category, true);

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

        return Ok(PatternMapper.ToDetailDto(result));
    }

    [Authorize(Policy = "RequireAdmin")]
    [HttpDelete("{id:guid}")]
    public async Task<ActionResult> DeletePattern(Guid id, CancellationToken ct = default)
    {
        var deleted = await _patternService.DeletePatternAsync(id, ct);
        if (!deleted) return NotFound();

        return NoContent();
    }
}
