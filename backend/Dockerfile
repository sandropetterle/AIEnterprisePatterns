# ============================================================================
# Backend API Dockerfile - Multi-stage build for optimal size
# AI Enterprise Patterns - ASP.NET Core 8.0
# ============================================================================

# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project files
COPY ["src/AIEnterprisePatterns.Api/AIEnterprisePatterns.Api.csproj", "src/AIEnterprisePatterns.Api/"]
COPY ["src/AIEnterprisePatterns.Core/AIEnterprisePatterns.Core.csproj", "src/AIEnterprisePatterns.Core/"]
COPY ["src/AIEnterprisePatterns.Data/AIEnterprisePatterns.Data.csproj", "src/AIEnterprisePatterns.Data/"]
COPY ["src/AIEnterprisePatterns.Infrastructure/AIEnterprisePatterns.Infrastructure.csproj", "src/AIEnterprisePatterns.Infrastructure/"]

# Restore dependencies
RUN dotnet restore "src/AIEnterprisePatterns.Api/AIEnterprisePatterns.Api.csproj"

# Copy all source files
COPY . .

# Build and publish
WORKDIR "/src/src/AIEnterprisePatterns.Api"
RUN dotnet build "AIEnterprisePatterns.Api.csproj" -c Release -o /app/build
RUN dotnet publish "AIEnterprisePatterns.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Create non-root user for security
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy published app from build stage
COPY --from=build /app/publish .

# Set ownership
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port (Container Apps uses port 80 by default)
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:80/health || exit 1

# Set environment variables
ENV ASPNETCORE_URLS=http://+:80
ENV ASPNETCORE_ENVIRONMENT=Production

# Start the application
ENTRYPOINT ["dotnet", "AIEnterprisePatterns.Api.dll"]
