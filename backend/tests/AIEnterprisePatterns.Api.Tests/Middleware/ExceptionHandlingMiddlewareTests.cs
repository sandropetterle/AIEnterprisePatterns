using System.Text.Json;
using AIEnterprisePatterns.Api.Middleware;
using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.Features;
using Microsoft.Extensions.Logging.Abstractions;

namespace AIEnterprisePatterns.Api.Tests.Middleware;

public class ExceptionHandlingMiddlewareTests
{
    private static ExceptionHandlingMiddleware CreateMiddleware(RequestDelegate next)
        => new(next, NullLogger<ExceptionHandlingMiddleware>.Instance);

    [Fact]
    public async Task UnhandledException_Returns500WithTraceId()
    {
        var context = new DefaultHttpContext { TraceIdentifier = "trace-abc" };
        context.Response.Body = new MemoryStream();
        var middleware = CreateMiddleware(_ => throw new InvalidOperationException("boom"));

        await middleware.InvokeAsync(context);

        context.Response.StatusCode.Should().Be(StatusCodes.Status500InternalServerError);
        context.Response.Body.Position = 0;
        using var body = await JsonDocument.ParseAsync(context.Response.Body);
        body.RootElement.GetProperty("status").GetInt32().Should().Be(500);
        body.RootElement.GetProperty("message").GetString().Should().Be("An internal server error occurred.");
        body.RootElement.GetProperty("traceId").GetString().Should().Be("trace-abc");
    }

    [Fact]
    public async Task UnhandledException_DoesNotLeakExceptionDetails()
    {
        var context = new DefaultHttpContext();
        context.Response.Body = new MemoryStream();
        var middleware = CreateMiddleware(_ => throw new InvalidOperationException("secret-internal-detail"));

        await middleware.InvokeAsync(context);

        context.Response.Body.Position = 0;
        var text = await new StreamReader(context.Response.Body).ReadToEndAsync();
        text.Should().NotContain("secret-internal-detail");
    }

    [Fact]
    public async Task UnhandledException_AfterResponseStarted_Rethrows()
    {
        var context = new DefaultHttpContext();
        context.Features.Set<IHttpResponseFeature>(new StartedResponseFeature());
        var middleware = CreateMiddleware(_ => throw new InvalidOperationException("mid-stream"));

        var act = () => middleware.InvokeAsync(context);

        await act.Should().ThrowAsync<InvalidOperationException>().WithMessage("mid-stream");
    }

    [Fact]
    public async Task ClientCancellation_IsSwallowed()
    {
        using var cts = new CancellationTokenSource();
        cts.Cancel();
        var context = new DefaultHttpContext { RequestAborted = cts.Token };
        var middleware = CreateMiddleware(_ => throw new OperationCanceledException());

        var act = () => middleware.InvokeAsync(context);

        await act.Should().NotThrowAsync();
    }

    private sealed class StartedResponseFeature : HttpResponseFeature
    {
        public override bool HasStarted => true;
    }
}
