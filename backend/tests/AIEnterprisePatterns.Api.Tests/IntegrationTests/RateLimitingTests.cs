using System.Diagnostics;
using System.Net;
using AIEnterprisePatterns.Data;
using AwesomeAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;

namespace AIEnterprisePatterns.Api.Tests.IntegrationTests;

public class RateLimitingTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public RateLimitingTests(WebApplicationFactory<Program> factory)
    {
        var configured = factory.WithWebHostBuilder(builder =>
        {
            builder.ConfigureServices(services =>
            {
                // See PatternEndpointsTests for why both descriptors must be removed
                // (EF Core 9+ chains provider config via IDbContextOptionsConfiguration<T>).
                services.RemoveAll<DbContextOptions<ApplicationDbContext>>();
                services.RemoveAll<IDbContextOptionsConfiguration<ApplicationDbContext>>();

                services.AddDbContext<ApplicationDbContext>(options =>
                    options.UseInMemoryDatabase($"RateLimitTestDb_{Guid.NewGuid()}"));
            });
        });

        _client = configured.CreateClient();
    }

    // Issue #68 regression guard: the "api" limiter used to be a single global
    // bucket (50/min, queue of 5, OldestFirst) shared by every client. Request
    // #51 within a minute silently sat in the limiter queue for up to ~55s,
    // hanging every SSR render behind it — each /patterns listing render
    // issues 2 API calls, so a handful of concurrent users (or one parallel
    // e2e run) exhausted the budget. A burst of legitimate browsing traffic
    // must be neither queued nor rejected.
    [Fact]
    public async Task GetPatterns_BurstAboveOldGlobalBudget_IsNeitherQueuedNorRejected()
    {
        var stopwatch = Stopwatch.StartNew();

        for (var i = 0; i < 60; i++)
        {
            var response = await _client.GetAsync("/api/patterns?page=1&pageSize=9");
            response.StatusCode.Should().Be(
                HttpStatusCode.OK, $"request #{i + 1} should not be rate limited");
        }

        stopwatch.Stop();
        // Generous bound: 60 in-memory requests complete in a couple of
        // seconds unless one is sitting in the rate limiter queue, which only
        // releases when the sliding window rolls (15-60s).
        stopwatch.Elapsed.Should().BeLessThan(TimeSpan.FromSeconds(10),
            "requests above the old global 50/min budget must not hang in the limiter queue");
    }
}
