using AIEnterprisePatterns.Api.Controllers;
using AIEnterprisePatterns.Api.DTOs;
using AIEnterprisePatterns.Api.Validators;
using AIEnterprisePatterns.Core.Entities;
using AIEnterprisePatterns.Core.Enums;
using AIEnterprisePatterns.Core.Services;
using AwesomeAssertions;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.DependencyInjection;
using Moq;

namespace AIEnterprisePatterns.Api.Tests.Controllers;

/// <summary>
/// Unit tests for the explicit FluentValidation calls in PatternsController (Decision 94):
/// invalid DTOs short-circuit to a ValidationProblemDetails 400 before any service call,
/// valid DTOs pass through to the service.
/// </summary>
public class PatternsControllerValidationTests
{
    private readonly Mock<IPatternService> _service = new(MockBehavior.Strict);
    private readonly PatternsController _controller;

    public PatternsControllerValidationTests()
    {
        _controller = new PatternsController(
            _service.Object, new CreatePatternDtoValidator(), new UpdatePatternDtoValidator())
        {
            ControllerContext = new ControllerContext
            {
                // Real MVC services so ValidationProblem() uses the same ProblemDetailsFactory as the app.
                HttpContext = new DefaultHttpContext
                {
                    RequestServices = new ServiceCollection().AddLogging().AddMvcCore().Services.BuildServiceProvider()
                }
            }
        };
    }

    private static CreatePatternDto ValidCreateDto() => new()
    {
        Title = "Title", ShortDescription = "Desc", FullContent = "Content",
        Category = "Architecture", Author = "Author", Tags = new List<string> { "Testing" }
    };

    private static UpdatePatternDto ValidUpdateDto() => new()
    {
        Title = "Title", ShortDescription = "Desc", FullContent = "Content",
        Category = "Security", Author = "Author", Tags = new List<string> { "Security" }
    };

    private static Pattern PatternFrom(string title, PatternCategory category) => new()
    {
        Id = Guid.NewGuid(), Title = title, Slug = "title", ShortDescription = "Desc",
        Category = category, CreatedDate = DateTime.UtcNow, UpdatedDate = DateTime.UtcNow
    };

    private static ValidationProblemDetails AssertValidationProblem(ActionResult? result)
    {
        var objectResult = result.Should().BeAssignableTo<ObjectResult>().Subject;
        objectResult.StatusCode.Should().Be(StatusCodes.Status400BadRequest);
        var problem = objectResult.Value.Should().BeOfType<ValidationProblemDetails>().Subject;
        problem.Status.Should().Be(400);
        problem.Title.Should().Be("One or more validation errors occurred.");
        problem.Type.Should().Be("https://tools.ietf.org/html/rfc9110#section-15.5.1");
        return problem;
    }

    [Fact]
    public async Task CreatePattern_InvalidDto_Returns400WithErrorsAndSkipsService()
    {
        var dto = ValidCreateDto();
        dto.Title = "";
        dto.Category = "NotACategory";
        dto.Tags = Enumerable.Range(0, 11).Select(i => $"tag{i}").ToList();

        var result = await _controller.CreatePattern(dto, CancellationToken.None);

        var problem = AssertValidationProblem(result.Result);
        problem.Errors.Keys.Should().BeEquivalentTo("Title", "Category", "Tags");
        problem.Errors["Title"].Should().Equal("'Title' must not be empty.");
        problem.Errors["Category"].Should().ContainSingle().Which.Should().StartWith("Invalid category.");
        problem.Errors["Tags"].Should().Equal("Maximum 10 tags allowed.");
        _service.VerifyNoOtherCalls();
    }

    [Fact]
    public async Task CreatePattern_WhitespaceTag_UsesIndexedPropertyPathAsKey()
    {
        var dto = ValidCreateDto();
        dto.Tags = new List<string> { "ok", " " };

        var result = await _controller.CreatePattern(dto, CancellationToken.None);

        var problem = AssertValidationProblem(result.Result);
        problem.Errors.Should().ContainKey("Tags[1]")
            .WhoseValue.Should().Equal("Tags must not be empty or whitespace.");
        _service.VerifyNoOtherCalls();
    }

    [Fact]
    public async Task CreatePattern_ValidDto_CallsServiceAndReturns201()
    {
        var dto = ValidCreateDto();
        _service
            .Setup(s => s.CreatePatternAsync(It.IsAny<Pattern>(), It.IsAny<List<string>>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((Pattern p, List<string> _, CancellationToken _) => PatternFrom(p.Title, p.Category));

        var result = await _controller.CreatePattern(dto, CancellationToken.None);

        var created = result.Result.Should().BeOfType<CreatedAtActionResult>().Subject;
        created.Value.Should().BeOfType<PatternDetailDto>().Which.Title.Should().Be("Title");
        _service.Verify(s => s.CreatePatternAsync(
            It.Is<Pattern>(p => p.Category == PatternCategory.Architecture), dto.Tags, It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task UpdatePattern_InvalidDto_Returns400WithErrorsAndSkipsService()
    {
        var dto = ValidUpdateDto();
        dto.ShortDescription = "";
        dto.Category = "NotACategory";

        var result = await _controller.UpdatePattern(Guid.NewGuid(), dto, CancellationToken.None);

        var problem = AssertValidationProblem(result.Result);
        problem.Errors.Keys.Should().BeEquivalentTo("ShortDescription", "Category");
        problem.Errors["ShortDescription"].Should().Equal("'Short Description' must not be empty.");
        _service.VerifyNoOtherCalls();
    }

    [Fact]
    public async Task UpdatePattern_ValidDto_CallsServiceAndReturns200()
    {
        var id = Guid.NewGuid();
        var dto = ValidUpdateDto();
        _service
            .Setup(s => s.UpdatePatternAsync(id, It.IsAny<Pattern>(), It.IsAny<List<string>>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((Guid _, Pattern p, List<string> _, CancellationToken _) => PatternFrom(p.Title, p.Category));

        var result = await _controller.UpdatePattern(id, dto, CancellationToken.None);

        result.Result.Should().BeOfType<OkObjectResult>()
            .Which.Value.Should().BeOfType<PatternDetailDto>().Which.Title.Should().Be("Title");
        _service.Verify(s => s.UpdatePatternAsync(
            id, It.Is<Pattern>(p => p.Category == PatternCategory.Security), dto.Tags, It.IsAny<CancellationToken>()), Times.Once);
    }
}
