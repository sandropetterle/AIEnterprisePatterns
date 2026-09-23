using System.Diagnostics;
using System.Net;
using System.Text.Json;

namespace AIEnterprisePatterns.Api.Middleware;

public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;

    public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (OperationCanceledException) when (context.RequestAborted.IsCancellationRequested)
        {
            _logger.LogInformation("Request cancelled by client: {Method} {Path}",
                context.Request.Method, context.Request.Path);
        }
        catch (Exception ex)
        {
            // Correlation id shared by the log entry and the response body, so a user-visible 500
            // can be matched to its App Insights trace (issue #144).
            var traceId = Activity.Current?.Id ?? context.TraceIdentifier;
            _logger.LogError(ex, "An unhandled exception occurred (traceId {TraceId})", traceId);

            // Headers/body already sent: the status can no longer be changed, and writing a JSON
            // error into a half-streamed response would corrupt it. Let the server abort it.
            if (context.Response.HasStarted)
            {
                throw;
            }

            await HandleExceptionAsync(context, traceId);
        }
    }

    private static async Task HandleExceptionAsync(HttpContext context, string traceId)
    {
        context.Response.ContentType = "application/json";
        context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;

        var response = new
        {
            status = context.Response.StatusCode,
            message = "An internal server error occurred.",
            traceId
        };

        await context.Response.WriteAsync(JsonSerializer.Serialize(response));
    }
}
