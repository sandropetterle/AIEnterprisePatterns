using AIEnterprisePatterns.Data;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using System.Threading.RateLimiting;

namespace AIEnterprisePatterns.Infrastructure;

public static class InfrastructureServiceCollectionExtensions
{
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        // Application Insights — monitoring and telemetry
        services.AddApplicationInsightsTelemetry(options =>
        {
            options.ConnectionString = configuration["ApplicationInsights:ConnectionString"];
            options.EnableAdaptiveSampling = true;
            options.EnableQuickPulseMetricStream = true;
        });

        // Caching and time abstraction
        services.AddMemoryCache();
        services.AddSingleton(TimeProvider.System);

        // Health checks
        services.AddHealthChecks()
            .AddDbContextCheck<ApplicationDbContext>();

        // Rate limiting — protect against abuse.
        //
        // All policies are partitioned per client IP. The previous named-window
        // limiters were single global buckets shared by every client, so a
        // handful of concurrent users exhausted the 50/min "api" budget (each
        // /patterns listing render issues 2 API calls) and subsequent requests
        // silently sat in the limiter queue for up to ~55s, hanging SSR renders
        // and e2e runs (issue #68). QueueLimit = 0 everywhere: reject promptly
        // with 429 instead of stalling the caller — the frontend handles
        // failures with fallbacks, and a visible 429 is diagnosable.
        services.AddRateLimiter(options =>
        {
            options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;

            // Fixed window: 100 requests per minute per client IP
            options.AddPolicy("fixed", httpContext =>
                RateLimitPartition.GetFixedWindowLimiter(
                    ClientKey(httpContext),
                    _ => new FixedWindowRateLimiterOptions
                    {
                        Window = TimeSpan.FromMinutes(1),
                        PermitLimit = 100,
                        QueueLimit = 0,
                    }));

            // Sliding window for API endpoints: 300 requests per minute per
            // client IP (~5 rps sustained) — generous enough for SSR-driven
            // browsing and e2e runs, still a meaningful abuse ceiling.
            options.AddPolicy("api", httpContext =>
                RateLimitPartition.GetSlidingWindowLimiter(
                    ClientKey(httpContext),
                    _ => new SlidingWindowRateLimiterOptions
                    {
                        Window = TimeSpan.FromMinutes(1),
                        SegmentsPerWindow = 4,
                        PermitLimit = 300,
                        QueueLimit = 0,
                    }));

            // Strict limiter for vote endpoint: 10 votes per minute per client IP
            options.AddPolicy("vote", httpContext =>
                RateLimitPartition.GetFixedWindowLimiter(
                    ClientKey(httpContext),
                    _ => new FixedWindowRateLimiterOptions
                    {
                        Window = TimeSpan.FromMinutes(1),
                        PermitLimit = 10,
                        QueueLimit = 0,
                    }));
        });

        return services;
    }

    /// <summary>
    /// Rate limit partition key — client IP, falling back to a shared bucket
    /// when the address is unavailable (e.g. in-memory TestServer).
    /// </summary>
    private static string ClientKey(HttpContext httpContext) =>
        httpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";
}
