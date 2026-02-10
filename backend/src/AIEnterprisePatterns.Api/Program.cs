using AIEnterprisePatterns.Api.Middleware;
using AIEnterprisePatterns.Core.Interfaces;
using AIEnterprisePatterns.Core.Services;
using AIEnterprisePatterns.Data;
using AIEnterprisePatterns.Data.Repositories;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

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

// CORS for Next.js frontend
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
        policy.WithOrigins("http://localhost:3000")
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials());
});

// Register repositories and services
builder.Services.AddScoped<IPatternRepository, PatternRepository>();
builder.Services.AddScoped<ITagRepository, TagRepository>();
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
builder.Services.AddScoped<IPatternService, PatternService>();

var app = builder.Build();

// Exception handling middleware
app.UseMiddleware<ExceptionHandlingMiddleware>();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();

    // Apply migrations on startup in development
    using var scope = app.Services.CreateScope();
    var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    await dbContext.Database.MigrateAsync();
}

app.UseCors("AllowFrontend");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
