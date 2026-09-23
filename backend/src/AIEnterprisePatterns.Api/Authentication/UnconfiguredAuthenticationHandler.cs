using System.Text.Encodings.Web;
using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Options;

namespace AIEnterprisePatterns.Api.Authentication;

/// <summary>
/// Fallback scheme registered in Development when no OIDC authority is configured.
/// It never authenticates anyone, so [Authorize] endpoints answer 401 (challenge) or
/// 403 (forbid) instead of throwing "No authenticationScheme was specified" and
/// surfacing as a 500 (issue #144). Outside Development a missing authority is a
/// startup error, so this handler is never used there.
/// </summary>
public class UnconfiguredAuthenticationHandler : AuthenticationHandler<AuthenticationSchemeOptions>
{
    public const string SchemeName = "Unconfigured";

    public UnconfiguredAuthenticationHandler(
        IOptionsMonitor<AuthenticationSchemeOptions> options,
        ILoggerFactory logger,
        UrlEncoder encoder)
        : base(options, logger, encoder)
    {
    }

    protected override Task<AuthenticateResult> HandleAuthenticateAsync()
        => Task.FromResult(AuthenticateResult.NoResult());
}
