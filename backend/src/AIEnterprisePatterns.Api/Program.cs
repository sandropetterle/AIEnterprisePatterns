using AIEnterprisePatterns.Api.Middleware;
using AIEnterprisePatterns.Core.Interfaces;
using AIEnterprisePatterns.Core.Services;
using AIEnterprisePatterns.Data;
using AIEnterprisePatterns.Data.Repositories;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.RateLimiting;
using System.Threading.RateLimiting;

var builder = WebApplication.CreateBuilder(args);

// Application Insights - Monitoring and telemetry
builder.Services.AddApplicationInsightsTelemetry(options =>
{
    options.ConnectionString = builder.Configuration["ApplicationInsights:ConnectionString"];
    options.EnableAdaptiveSampling = true;
    options.EnableQuickPulseMetricStream = true;
});

// Controllers and Swagger
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo
    {
        Title = "AI Enterprise Patterns API",
        Version = "v1",
        Description = "RESTful API for managing AI enterprise patterns"
    });
});

// Database - Use SQLite for local dev, SQL Server for production
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
if (builder.Environment.IsDevelopment() && (string.IsNullOrEmpty(connectionString) || connectionString.Contains("localhost,1433")))
{
    var dbPath = Path.Combine(AppContext.BaseDirectory, "aipatterns.db");
    builder.Services.AddDbContext<ApplicationDbContext>(options =>
        options.UseSqlite($"Data Source={dbPath}"));
}
else
{
    builder.Services.AddDbContext<ApplicationDbContext>(options =>
        options.UseSqlServer(connectionString,
            sqlOptions => sqlOptions.EnableRetryOnFailure()));
}

// CORS for Next.js frontend - Environment-specific
var frontendUrls = new List<string> { "http://localhost:3000" };
var productionFrontendUrl = builder.Configuration["FrontendUrl"];
if (!string.IsNullOrEmpty(productionFrontendUrl))
{
    frontendUrls.Add(productionFrontendUrl);
}

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
        policy.WithOrigins(frontendUrls.ToArray())
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials());
});

// Register repositories and services
builder.Services.AddScoped<IPatternRepository, PatternRepository>();
builder.Services.AddScoped<ITagRepository, TagRepository>();
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
builder.Services.AddScoped<IPatternService, PatternService>();

// Health checks
builder.Services.AddHealthChecks()
    .AddDbContextCheck<ApplicationDbContext>();

// Rate limiting - Protect against abuse
builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;

    // Fixed window rate limiter: 100 requests per minute per IP
    options.AddFixedWindowLimiter("fixed", config =>
    {
        config.Window = TimeSpan.FromMinutes(1);
        config.PermitLimit = 100;
        config.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
        config.QueueLimit = 10;
    });

    // Sliding window for API endpoints: 50 requests per minute
    options.AddSlidingWindowLimiter("api", config =>
    {
        config.Window = TimeSpan.FromMinutes(1);
        config.SegmentsPerWindow = 4;
        config.PermitLimit = 50;
        config.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
        config.QueueLimit = 5;
    });
});

var app = builder.Build();

// Exception handling middleware
app.UseMiddleware<ExceptionHandlingMiddleware>();

// Swagger - Enable in production for Azure Portal
app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "AI Enterprise Patterns API v1");
    c.RoutePrefix = "swagger";
});

// Apply database migrations on startup (development only)
if (app.Environment.IsDevelopment())
{
    using var scope = app.Services.CreateScope();
    var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    await dbContext.Database.MigrateAsync();
}

// Health check endpoints
app.MapHealthChecks("/health");
app.MapHealthChecks("/health/ready");

// Security headers
app.Use(async (context, next) =>
{
    context.Response.Headers.Append("X-Content-Type-Options", "nosniff");
    context.Response.Headers.Append("X-Frame-Options", "DENY");
    context.Response.Headers.Append("X-XSS-Protection", "1; mode=block");
    context.Response.Headers.Append("Referrer-Policy", "strict-origin-when-cross-origin");
    await next();
});

app.UseCors("AllowFrontend");
app.UseRateLimiter();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers().RequireRateLimiting("api");

app.Run();
