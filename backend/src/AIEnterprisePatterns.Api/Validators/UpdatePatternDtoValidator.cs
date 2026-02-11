using AIEnterprisePatterns.Api.DTOs;
using AIEnterprisePatterns.Core.Enums;
using FluentValidation;

namespace AIEnterprisePatterns.Api.Validators;

public class UpdatePatternDtoValidator : AbstractValidator<UpdatePatternDto>
{
    public UpdatePatternDtoValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty()
            .MaximumLength(255);

        RuleFor(x => x.ShortDescription)
            .NotEmpty()
            .MaximumLength(500);

        RuleFor(x => x.FullContent)
            .MaximumLength(50000);

        RuleFor(x => x.Category)
            .NotEmpty()
            .Must(c => Enum.TryParse<PatternCategory>(c, true, out _))
            .WithMessage("Invalid category. Valid values: " +
                string.Join(", ", Enum.GetNames<PatternCategory>()));

        RuleFor(x => x.Tags)
            .Must(t => t.Count <= 10)
            .WithMessage("Maximum 10 tags allowed.");

        RuleForEach(x => x.Tags)
            .NotEmpty()
            .MaximumLength(50);

        RuleFor(x => x.Author)
            .MaximumLength(100);
    }
}
