import { Pattern } from '@/lib/types/pattern'

export const mockPatterns: Pattern[] = [
  {
    id: '1',
    title: 'Clean Architecture with AI-Assisted Refactoring',
    slug: 'clean-architecture-ai-refactoring',
    shortDescription: 'Learn how to leverage AI tools to refactor legacy code into clean architecture patterns, including layered separation and dependency injection.',
    fullContent: `## Overview

Clean Architecture is a software design philosophy that emphasizes separation of concerns through well-defined layers. This pattern combines traditional Clean Architecture principles with modern AI-assisted refactoring techniques to modernize legacy codebases efficiently.

## Problem Statement

Legacy codebases often suffer from tight coupling, poor separation of concerns, and monolithic structures that make them difficult to maintain, test, and scale. Manual refactoring is time-consuming, error-prone, and requires deep understanding of the entire system. Teams need a systematic approach to transform legacy code into clean, maintainable architecture while minimizing risks and downtime.

## Proposed Solution

Leverage AI assistants like Claude to analyze code structure, identify architectural violations, and suggest refactoring strategies. The approach combines automated analysis with human oversight to progressively refactor code into Clean Architecture layers: Entities, Use Cases, Interface Adapters, and Frameworks & Drivers.

## AI Prompt Examples

\`\`\`
Analyze this C# class and identify violations of Clean Architecture principles. Suggest how to separate business logic from infrastructure concerns:

[Paste your code here]

Focus on:
1. Dependency direction (should point inward)
2. Business logic mixed with framework code
3. Direct database access in business logic
4. Hard-coded dependencies
\`\`\`

\`\`\`
Refactor this service class to follow Clean Architecture. Create separate layers for:
- Domain entities (core business objects)
- Use cases (application business rules)
- Interface adapters (controllers, presenters)
- Infrastructure (database, external services)

[Paste service class code]
\`\`\`

## Implementation Steps

1. **Assess Current State**: Use AI to analyze your codebase and identify architectural issues, dependencies, and coupling points.

2. **Define Layer Boundaries**: Establish clear boundaries for Domain, Application, Infrastructure, and Presentation layers following Clean Architecture principles.

3. **Create Domain Layer**: Extract pure business entities and value objects. These should have no dependencies on frameworks or infrastructure.

4. **Implement Use Cases**: Move business logic into use case classes (commands/queries). Use dependency inversion to reference infrastructure through interfaces.

5. **Introduce Dependency Injection**: Configure DI container to wire up dependencies, ensuring outer layers depend on inner layers through abstractions.

6. **Refactor Infrastructure**: Move database access, external API calls, and framework-specific code into infrastructure layer implementing domain interfaces.

7. **Add Tests**: Write unit tests for domain and use cases (easy to test with no infrastructure dependencies), integration tests for infrastructure.

## Trade-offs

### Pros
- **Testability**: Business logic isolated from infrastructure enables fast, reliable unit tests
- **Maintainability**: Clear separation makes code easier to understand and modify
- **Flexibility**: Easy to swap implementations (e.g., change database, add caching) without affecting business logic
- **AI-Assisted Speed**: AI tools accelerate refactoring and reduce human error
- **Independent of Frameworks**: Business logic doesn't depend on UI frameworks or databases

### Cons
- **Initial Complexity**: More layers and abstractions can seem over-engineered for simple applications
- **Learning Curve**: Team needs to understand Clean Architecture principles
- **More Files**: Separation into layers creates more classes and interfaces
- **AI Limitations**: AI suggestions require human review and validation
- **Refactoring Time**: Large legacy systems take time to refactor incrementally

## Code Samples

\`\`\`csharp
// Domain Layer - Pure business entity
namespace Domain.Entities
{
    public class Order
    {
        public Guid Id { get; private set; }
        public string CustomerName { get; private set; }
        public List<OrderItem> Items { get; private set; }
        public OrderStatus Status { get; private set; }

        public void AddItem(OrderItem item)
        {
            if (Status != OrderStatus.Draft)
                throw new InvalidOperationException("Cannot modify confirmed order");
            Items.Add(item);
        }

        public decimal GetTotal() => Items.Sum(i => i.Price * i.Quantity);
    }
}

// Application Layer - Use case
namespace Application.UseCases
{
    public class CreateOrderUseCase
    {
        private readonly IOrderRepository _orderRepository;
        private readonly IEmailService _emailService;

        public CreateOrderUseCase(IOrderRepository orderRepository, IEmailService emailService)
        {
            _orderRepository = orderRepository;
            _emailService = emailService;
        }

        public async Task<Guid> ExecuteAsync(CreateOrderRequest request)
        {
            var order = new Order(request.CustomerName);
            foreach (var item in request.Items)
            {
                order.AddItem(new OrderItem(item.ProductId, item.Quantity, item.Price));
            }

            await _orderRepository.SaveAsync(order);
            await _emailService.SendOrderConfirmationAsync(order);

            return order.Id;
        }
    }
}

// Infrastructure Layer - Repository implementation
namespace Infrastructure.Persistence
{
    public class OrderRepository : IOrderRepository
    {
        private readonly ApplicationDbContext _context;

        public OrderRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<Order> GetByIdAsync(Guid id)
        {
            var orderEntity = await _context.Orders
                .Include(o => o.Items)
                .FirstOrDefaultAsync(o => o.Id == id);

            return orderEntity?.ToDomainModel();
        }

        public async Task SaveAsync(Order order)
        {
            var entity = OrderEntity.FromDomainModel(order);
            _context.Orders.Add(entity);
            await _context.SaveChangesAsync();
        }
    }
}
\`\`\`
`,
    category: 'Architecture',
    tags: ['Clean Architecture', 'Refactoring', 'AI-Assisted'],
    author: 'John Doe',
    createdDate: '2024-01-15T10:00:00Z',
    updatedDate: '2024-01-20T14:30:00Z',
    voteCount: 42,
    status: 'published',
    isFeatured: true,
  },
  {
    id: '2',
    title: 'Repository Pattern with Entity Framework Core',
    slug: 'repository-pattern-ef-core',
    shortDescription: 'Implement the Repository pattern using EF Core with best practices for unit testing, async operations, and generic repositories.',
    fullContent: `## Overview

The Repository pattern provides an abstraction layer between the domain/business logic and data access logic. When combined with Entity Framework Core, it enables better testability, maintainability, and separation of concerns in your application architecture.

## Problem Statement

Direct use of Entity Framework DbContext throughout application layers leads to tight coupling with the data access technology, makes unit testing difficult (requires database), and violates the Dependency Inversion Principle. Business logic becomes intertwined with data access concerns, and changing ORM frameworks or data storage strategies becomes costly.

## Proposed Solution

Implement the Repository pattern by creating abstraction interfaces that define data operations, and concrete implementations using EF Core. Use generic repositories for common CRUD operations and specific repositories for complex domain queries. Combine with Unit of Work pattern for transaction management.

## AI Prompt Examples

\`\`\`
Create a generic repository interface and implementation for Entity Framework Core that supports:
- Async CRUD operations
- Query filtering with expression trees
- Paging support
- Include related entities
- Soft delete functionality

Provide both the interface and EF Core implementation.
\`\`\`

\`\`\`
Review this repository implementation for potential issues:
[Paste code]

Check for:
- Proper async/await usage
- Memory leaks (IQueryable disposal)
- N+1 query problems
- Missing cancellation token support
- Testability concerns
\`\`\`

## Implementation Steps

1. **Define Repository Interfaces**: Create IRepository<T> generic interface with common CRUD operations (GetById, GetAll, Add, Update, Delete, Find).

2. **Implement Generic Repository**: Create base repository class implementing IRepository<T> using EF Core DbContext and DbSet<T>.

3. **Create Specific Repositories**: For entities with complex queries, create specific repository interfaces (e.g., IOrderRepository) inheriting from IRepository<Order>.

4. **Implement Unit of Work**: Create IUnitOfWork interface to manage transactions and coordinate multiple repository operations.

5. **Configure Dependency Injection**: Register repositories and Unit of Work in DI container with appropriate lifetimes (typically scoped).

6. **Write Repository Tests**: Create unit tests using in-memory database or mocked DbContext to verify repository behavior.

7. **Use in Application Layer**: Inject repositories into services/use cases instead of DbContext directly.

## Trade-offs

### Pros
- **Testability**: Easy to mock repositories for unit testing business logic
- **Abstraction**: Decouples business logic from specific ORM implementation
- **Centralized Data Access**: All data operations in one place, easier to maintain
- **Flexibility**: Can switch ORMs or add caching without changing business logic
- **Clean Code**: Removes EF Core specific code from business layer

### Cons
- **Extra Layer**: Adds abstraction overhead, may be overkill for simple CRUD apps
- **Leaky Abstraction**: IQueryable can expose EF Core concepts to business layer
- **Performance**: Generic repositories might not be optimized for specific queries
- **Learning Curve**: Developers need to understand both pattern and EF Core
- **Code Duplication**: Similar methods across multiple specific repositories

## Code Samples

\`\`\`csharp
// Generic Repository Interface
public interface IRepository<T> where T : class
{
    Task<T?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IEnumerable<T>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> predicate, CancellationToken cancellationToken = default);
    Task AddAsync(T entity, CancellationToken cancellationToken = default);
    void Update(T entity);
    void Delete(T entity);
}

// Generic Repository Implementation
public class Repository<T> : IRepository<T> where T : class
{
    protected readonly ApplicationDbContext _context;
    protected readonly DbSet<T> _dbSet;

    public Repository(ApplicationDbContext context)
    {
        _context = context;
        _dbSet = context.Set<T>();
    }

    public async Task<T?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _dbSet.FindAsync(new object[] { id }, cancellationToken);
    }

    public async Task<IEnumerable<T>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _dbSet.ToListAsync(cancellationToken);
    }

    public async Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> predicate, CancellationToken cancellationToken = default)
    {
        return await _dbSet.Where(predicate).ToListAsync(cancellationToken);
    }

    public async Task AddAsync(T entity, CancellationToken cancellationToken = default)
    {
        await _dbSet.AddAsync(entity, cancellationToken);
    }

    public void Update(T entity)
    {
        _dbSet.Update(entity);
    }

    public void Delete(T entity)
    {
        _dbSet.Remove(entity);
    }
}

// Specific Repository Interface
public interface IOrderRepository : IRepository<Order>
{
    Task<IEnumerable<Order>> GetOrdersByCustomerAsync(Guid customerId, CancellationToken cancellationToken = default);
    Task<Order?> GetOrderWithItemsAsync(Guid orderId, CancellationToken cancellationToken = default);
}

// Specific Repository Implementation
public class OrderRepository : Repository<Order>, IOrderRepository
{
    public OrderRepository(ApplicationDbContext context) : base(context) { }

    public async Task<IEnumerable<Order>> GetOrdersByCustomerAsync(Guid customerId, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(o => o.CustomerId == customerId)
            .Include(o => o.Items)
            .ToListAsync(cancellationToken);
    }

    public async Task<Order?> GetOrderWithItemsAsync(Guid orderId, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(o => o.Items)
            .ThenInclude(i => i.Product)
            .FirstOrDefaultAsync(o => o.Id == orderId, cancellationToken);
    }
}

// Unit of Work Interface
public interface IUnitOfWork : IDisposable
{
    IOrderRepository Orders { get; }
    IProductRepository Products { get; }
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}

// Unit of Work Implementation
public class UnitOfWork : IUnitOfWork
{
    private readonly ApplicationDbContext _context;

    public IOrderRepository Orders { get; }
    public IProductRepository Products { get; }

    public UnitOfWork(ApplicationDbContext context, IOrderRepository orderRepository, IProductRepository productRepository)
    {
        _context = context;
        Orders = orderRepository;
        Products = productRepository;
    }

    public async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        return await _context.SaveChangesAsync(cancellationToken);
    }

    public void Dispose()
    {
        _context.Dispose();
    }
}
\`\`\`
`,
    category: 'Design Patterns',
    tags: ['Repository', 'EF Core', 'Testing'],
    author: 'Jane Smith',
    createdDate: '2024-01-18T09:00:00Z',
    updatedDate: '2024-01-18T09:00:00Z',
    voteCount: 38,
    status: 'published',
    isTrending: true,
  },
  {
    id: '3',
    title: 'AI Prompt Engineering for Code Review',
    slug: 'ai-prompt-code-review',
    shortDescription: 'Curated prompts for AI-assisted code reviews covering SOLID principles, security vulnerabilities, and performance optimization.',
    fullContent: `## Overview

AI-assisted code review leverages large language models to automate and enhance the code review process. This pattern provides proven prompt templates for systematically reviewing code quality, security, performance, and adherence to best practices using AI assistants like Claude.

## Problem Statement

Manual code reviews are time-consuming, inconsistent, and prone to human oversight. Reviewers may miss security vulnerabilities, performance issues, or violations of coding standards. Junior developers lack experience to provide thorough reviews, while senior developers don't have time to review every line. Teams need a way to augment human review with systematic, consistent AI analysis.

## Proposed Solution

Create a library of specialized prompts that guide AI assistants to perform focused code reviews from different perspectives: security, performance, SOLID principles, testing, error handling, and documentation. Combine AI reviews with human judgment for comprehensive quality assurance.

## AI Prompt Examples

\`\`\`
**SOLID Principles Review**

Review this code for violations of SOLID principles. For each violation:
1. Identify which principle is violated (SRP, OCP, LSP, ISP, or DIP)
2. Explain why it's a problem
3. Suggest a refactoring approach

[Paste code here]
\`\`\`

\`\`\`
**Security Vulnerability Scan**

Analyze this code for security vulnerabilities including but not limited to:
- SQL Injection
- Cross-Site Scripting (XSS)
- Cross-Site Request Forgery (CSRF)
- Insecure deserialization
- Sensitive data exposure
- Missing authentication/authorization
- Hardcoded secrets
- Path traversal

For each issue found, provide:
- Severity level (Critical/High/Medium/Low)
- Exploit scenario
- Remediation code example

[Paste code here]
\`\`\`

\`\`\`
**Performance Optimization Review**

Review this code for performance issues:
1. Inefficient algorithms (check Big O complexity)
2. N+1 query problems
3. Unnecessary object allocations
4. Missing caching opportunities
5. Synchronous operations that could be async
6. Resource leaks (unclosed connections, streams)
7. Boxing/unboxing in hot paths

Prioritize issues by performance impact and provide optimized code samples.

[Paste code here]
\`\`\`

\`\`\`
**Error Handling Review**

Evaluate error handling in this code:
- Are exceptions used appropriately?
- Is exception handling too broad or too narrow?
- Are error messages helpful and secure (no sensitive data)?
- Are resources properly cleaned up (using statements)?
- Are critical operations wrapped in try-catch?
- Is there proper logging of errors?
- Are custom exceptions used where appropriate?

[Paste code here]
\`\`\`

\`\`\`
**Test Coverage Analysis**

Review this code and identify:
1. Edge cases that aren't tested
2. Error paths that need test coverage
3. Boundary conditions to test
4. Integration points that need mocking
5. Race conditions or timing issues

Provide test case examples in [testing framework] format.

[Paste code here]
\`\`\`

## Implementation Steps

1. **Select Review Focus**: Choose which aspect to review (security, performance, SOLID, etc.) based on code context and risk.

2. **Prepare Code Context**: Include relevant surrounding code, interfaces, and dependencies to give AI sufficient context.

3. **Use Specific Prompts**: Apply the appropriate prompt template(s) from the library for focused analysis.

4. **Review AI Findings**: Critically evaluate AI suggestions - not all will be valid or relevant to your context.

5. **Prioritize Issues**: Triage findings by severity, impact, and effort to fix.

6. **Validate with Tests**: For refactoring suggestions, write tests before applying changes to ensure behavior preservation.

7. **Human Review**: Combine AI feedback with human reviewer's domain knowledge and business context.

8. **Document Patterns**: Add recurring issues to team guidelines and linting rules.

## Trade-offs

### Pros
- **Consistency**: Same standards applied to all code reviews
- **Speed**: Instant feedback, faster than waiting for human review
- **Learning Tool**: Junior developers learn from AI explanations and suggestions
- **Comprehensive**: AI can catch issues human reviewers miss
- **24/7 Availability**: Get reviews anytime, no waiting for reviewer availability

### Cons
- **False Positives**: AI may flag non-issues or suggest inappropriate changes
- **Context Limitations**: AI lacks full business context and system architecture knowledge
- **Over-Reliance**: Teams might skip critical human review thinking AI is sufficient
- **Token Costs**: Large codebases can be expensive to review with AI
- **Learning Curve**: Writing effective prompts requires practice

## Code Samples

\`\`\`csharp
// Example: Code with SOLID violations
// AI will identify SRP and DIP violations

public class UserService
{
    // Violates SRP: Too many responsibilities
    // Violates DIP: Depends on concrete implementation (SmtpClient)
    public async Task RegisterUser(string email, string password)
    {
        // Database operation
        var user = new User { Email = email, Password = HashPassword(password) };
        using var connection = new SqlConnection("connectionString");
        await connection.OpenAsync();
        var command = new SqlCommand("INSERT INTO Users...", connection);
        await command.ExecuteNonQueryAsync();

        // Email operation - different responsibility
        var smtpClient = new SmtpClient("smtp.server.com");
        var message = new MailMessage("from@example.com", email);
        message.Subject = "Welcome!";
        await smtpClient.SendAsync(message);

        // Logging - another responsibility
        File.AppendAllText("log.txt", $"User {email} registered at {DateTime.Now}");
    }

    private string HashPassword(string password)
    {
        // Password hashing logic
        return Convert.ToBase64String(SHA256.HashData(Encoding.UTF8.GetBytes(password)));
    }
}

// AI-suggested refactoring following SOLID:

public interface IUserRepository
{
    Task AddUserAsync(User user);
}

public interface IEmailService
{
    Task SendWelcomeEmailAsync(string email);
}

public interface ILogger
{
    void LogInfo(string message);
}

public class UserRegistrationService
{
    private readonly IUserRepository _userRepository;
    private readonly IEmailService _emailService;
    private readonly ILogger _logger;
    private readonly IPasswordHasher _passwordHasher;

    public UserRegistrationService(
        IUserRepository userRepository,
        IEmailService emailService,
        ILogger logger,
        IPasswordHasher passwordHasher)
    {
        _userRepository = userRepository;
        _emailService = emailService;
        _logger = logger;
        _passwordHasher = passwordHasher;
    }

    public async Task RegisterUserAsync(string email, string password)
    {
        var user = new User
        {
            Email = email,
            Password = _passwordHasher.Hash(password)
        };

        await _userRepository.AddUserAsync(user);
        await _emailService.SendWelcomeEmailAsync(email);
        _logger.LogInfo($"User {email} registered successfully");
    }
}
\`\`\`
`,
    category: 'AI Prompts',
    tags: ['Code Review', 'Prompts', 'SOLID'],
    author: 'Alice Johnson',
    createdDate: '2024-01-22T11:00:00Z',
    updatedDate: '2024-01-25T16:45:00Z',
    voteCount: 56,
    status: 'published',
    isFeatured: true,
    isTrending: true,
  },
  {
    id: '4',
    title: 'CQRS Pattern Implementation Guide',
    slug: 'cqrs-pattern-implementation',
    shortDescription: 'Complete guide to implementing Command Query Responsibility Segregation in .NET applications with MediatR and event sourcing.',
    fullContent: `## Overview

Command Query Responsibility Segregation (CQRS) is an architectural pattern that separates read and write operations into distinct models. Combined with MediatR for request handling and optional event sourcing, CQRS enables scalable, maintainable applications with clear separation of concerns.

## Problem Statement

Traditional CRUD applications use the same model for reads and writes, leading to complexity as the system grows. Complex domain models become bloated with properties needed only for queries. Performance suffers when read and write loads have different characteristics. Validation and business rules get mixed with data retrieval logic. Scaling reads and writes independently becomes difficult.

## Proposed Solution

Separate commands (writes) from queries (reads) using distinct models and handlers. Commands modify state and return void or simple results. Queries fetch data using optimized DTOs. Use MediatR to mediate between controllers and handlers, and optionally implement event sourcing for complete audit trails and temporal queries.

## AI Prompt Examples

\`\`\`
Design a CQRS implementation for an e-commerce order system with:
- Commands: CreateOrder, UpdateOrderStatus, CancelOrder
- Queries: GetOrderById, GetOrdersByCustomer, GetOrderSummary

Provide:
1. Command and Query classes
2. Handler implementations using MediatR
3. Validation using FluentValidation
4. Domain events for order state changes
\`\`\`

\`\`\`
Review this CQRS implementation for common pitfalls:
[Paste code]

Check for:
- Commands returning data (should return void or simple confirmation)
- Queries modifying state (should be read-only)
- Business logic in query handlers
- Missing validation in command handlers
- Inappropriate use of CQRS (over-engineering simple scenarios)
\`\`\`

## Implementation Steps

1. **Install Required Packages**: Add MediatR, MediatR.Extensions.Microsoft.DependencyInjection, and optionally FluentValidation to your project.

2. **Define Commands**: Create command classes representing write operations (CreateOrderCommand, UpdateProductCommand) that implement IRequest or IRequest<TResponse>.

3. **Define Queries**: Create query classes for read operations (GetOrderByIdQuery, GetProductsQuery) that implement IRequest<TResult>.

4. **Implement Command Handlers**: Create handler classes implementing IRequestHandler<TCommand, TResponse> with business logic and validation.

5. **Implement Query Handlers**: Create query handler classes that fetch data from read-optimized data stores or views.

6. **Configure MediatR**: Register MediatR and all handlers in DI container using services.AddMediatR().

7. **Add Pipeline Behaviors**: Implement cross-cutting concerns (validation, logging, transactions) as MediatR pipeline behaviors.

8. **Optional - Event Sourcing**: Store domain events instead of current state, rebuild state by replaying events.

## Trade-offs

### Pros
- **Separation of Concerns**: Clear distinction between reads and writes
- **Scalability**: Optimize and scale reads/writes independently
- **Performance**: Use different data models optimized for each operation
- **Simplified Domain Model**: Write model focuses on business rules, not queries
- **Flexibility**: Can use different databases for reads and writes
- **Auditability**: Event sourcing provides complete history

### Cons
- **Complexity**: More moving parts than simple CRUD
- **Eventual Consistency**: Read model may lag behind write model
- **Code Duplication**: Separate models mean more classes and mapping
- **Learning Curve**: Team needs to understand CQRS concepts
- **Overkill for Simple Apps**: Not every application needs this level of separation

## Code Samples

\`\`\`csharp
// Command - Write operation
public class CreateOrderCommand : IRequest<Guid>
{
    public string CustomerName { get; set; }
    public List<OrderItemDto> Items { get; set; }
}

// Command Handler
public class CreateOrderCommandHandler : IRequestHandler<CreateOrderCommand, Guid>
{
    private readonly ApplicationDbContext _context;
    private readonly IMediator _mediator;

    public CreateOrderCommandHandler(ApplicationDbContext context, IMediator mediator)
    {
        _context = context;
        _mediator = mediator;
    }

    public async Task<Guid> Handle(CreateOrderCommand request, CancellationToken cancellationToken)
    {
        // Business logic and validation
        var order = new Order
        {
            Id = Guid.NewGuid(),
            CustomerName = request.CustomerName,
            OrderDate = DateTime.UtcNow,
            Status = OrderStatus.Pending
        };

        foreach (var item in request.Items)
        {
            order.Items.Add(new OrderItem
            {
                ProductId = item.ProductId,
                Quantity = item.Quantity,
                Price = item.Price
            });
        }

        _context.Orders.Add(order);
        await _context.SaveChangesAsync(cancellationToken);

        // Publish domain event
        await _mediator.Publish(new OrderCreatedEvent(order.Id, order.CustomerName), cancellationToken);

        return order.Id;
    }
}

// Query - Read operation
public class GetOrderByIdQuery : IRequest<OrderDetailDto>
{
    public Guid OrderId { get; set; }
}

// Query Handler
public class GetOrderByIdQueryHandler : IRequestHandler<GetOrderByIdQuery, OrderDetailDto>
{
    private readonly IOrderReadRepository _readRepository;

    public GetOrderByIdQueryHandler(IOrderReadRepository readRepository)
    {
        _readRepository = readRepository;
    }

    public async Task<OrderDetailDto> Handle(GetOrderByIdQuery request, CancellationToken cancellationToken)
    {
        // Optimized read from read model (could be denormalized view)
        return await _readRepository.GetOrderDetailsAsync(request.OrderId, cancellationToken);
    }
}

// Domain Event
public record OrderCreatedEvent(Guid OrderId, string CustomerName) : INotification;

// Event Handler
public class OrderCreatedEventHandler : INotificationHandler<OrderCreatedEvent>
{
    private readonly IEmailService _emailService;
    private readonly ILogger<OrderCreatedEventHandler> _logger;

    public OrderCreatedEventHandler(IEmailService emailService, ILogger<OrderCreatedEventHandler> logger)
    {
        _emailService = emailService;
        _logger = logger;
    }

    public async Task Handle(OrderCreatedEvent notification, CancellationToken cancellationToken)
    {
        _logger.LogInformation($"Order {notification.OrderId} created for {notification.CustomerName}");
        await _emailService.SendOrderConfirmationAsync(notification.CustomerName, notification.OrderId);
    }
}

// Controller usage
[ApiController]
[Route("api/orders")]
public class OrdersController : ControllerBase
{
    private readonly IMediator _mediator;

    public OrdersController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpPost]
    public async Task<ActionResult<Guid>> CreateOrder(CreateOrderCommand command)
    {
        var orderId = await _mediator.Send(command);
        return CreatedAtAction(nameof(GetOrder), new { id = orderId }, orderId);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<OrderDetailDto>> GetOrder(Guid id)
    {
        var query = new GetOrderByIdQuery { OrderId = id };
        var result = await _mediator.Send(query);
        return result != null ? Ok(result) : NotFound();
    }
}

// Validation Pipeline Behavior
public class ValidationBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
{
    private readonly IEnumerable<IValidator<TRequest>> _validators;

    public ValidationBehavior(IEnumerable<IValidator<TRequest>> validators)
    {
        _validators = validators;
    }

    public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken cancellationToken)
    {
        if (_validators.Any())
        {
            var context = new ValidationContext<TRequest>(request);
            var validationResults = await Task.WhenAll(_validators.Select(v => v.ValidateAsync(context, cancellationToken)));
            var failures = validationResults.SelectMany(r => r.Errors).Where(f => f != null).ToList();

            if (failures.Count != 0)
                throw new ValidationException(failures);
        }

        return await next();
    }
}
\`\`\`
`,
    category: 'Architecture',
    tags: ['CQRS', 'MediatR', 'Event Sourcing'],
    author: 'Bob Williams',
    createdDate: '2024-01-10T08:00:00Z',
    updatedDate: '2024-01-10T08:00:00Z',
    voteCount: 34,
    status: 'published',
    isFeatured: true,
  },
  {
    id: '5',
    title: 'Microservices Security Best Practices',
    slug: 'microservices-security-practices',
    shortDescription: 'Essential security patterns for microservices including service-to-service authentication, API gateway security, and secret management.',
    fullContent: `## Overview

Microservices architecture introduces unique security challenges due to distributed nature, increased network communication, and multiple attack surfaces. This pattern provides comprehensive security best practices covering authentication, authorization, encryption, secret management, and API gateway security.

## Problem Statement

Microservices expose numerous endpoints across the network, creating multiple attack vectors. Traditional perimeter security is insufficient. Services need to authenticate each other, manage secrets securely, encrypt data in transit, handle distributed authorization, and protect against various attacks. Misconfigurations or security gaps in any service can compromise the entire system.

## Proposed Solution

Implement defense-in-depth strategy with multiple layers: API Gateway as single entry point with rate limiting and authentication, service-to-service authentication using mTLS or JWT, centralized secret management, encrypted communication, distributed tracing for security monitoring, and principle of least privilege for service permissions.

## AI Prompt Examples

\`\`\`
Design a secure microservices authentication and authorization flow using:
- OAuth 2.0 / OpenID Connect for external clients
- Service mesh (Istio) or JWT for service-to-service auth
- API Gateway for rate limiting and request validation
- Azure Key Vault or HashiCorp Vault for secrets

Provide configuration examples and code samples for .NET services.
\`\`\`

\`\`\`
Review this microservices architecture for security vulnerabilities:
[Paste architecture diagram or description]

Check for:
- Missing authentication between services
- Unencrypted service-to-service communication
- Secrets in configuration files
- Missing rate limiting
- Inadequate input validation
- Overly permissive CORS policies
- No network segmentation
\`\`\`

## Implementation Steps

1. **Implement API Gateway**: Deploy gateway (YARP, Ocelot, Kong) as single entry point for external requests with authentication, rate limiting, and request validation.

2. **Service-to-Service Authentication**: Implement mTLS or JWT-based authentication between internal services, ensure all service communication is authenticated.

3. **Centralize Secret Management**: Use Azure Key Vault, AWS Secrets Manager, or HashiCorp Vault to store connection strings, API keys, and certificates.

4. **Enable TLS Everywhere**: Configure TLS/HTTPS for all service communication, use certificate rotation policies.

5. **Implement Authorization**: Use OAuth 2.0 scopes and claims-based authorization, implement API-level permissions.

6. **Add Rate Limiting**: Implement rate limiting at API Gateway and individual service level to prevent DDoS and abuse.

7. **Network Segmentation**: Use network policies (Kubernetes Network Policies, Azure NSGs) to restrict service-to-service communication.

8. **Monitoring and Logging**: Implement centralized logging, security monitoring, and alerting for suspicious activities.

## Trade-offs

### Pros
- **Defense in Depth**: Multiple security layers protect against various attack vectors
- **Least Privilege**: Services only have access to resources they need
- **Auditability**: Comprehensive logging and monitoring of security events
- **Secret Security**: Centralized secret management prevents credential leaks
- **Scalable**: Security measures scale with service architecture

### Cons
- **Complexity**: More components to configure and maintain
- **Performance Overhead**: Encryption and authentication add latency
- **Certificate Management**: mTLS requires certificate lifecycle management
- **Debugging Harder**: Encrypted traffic harder to troubleshoot
- **Cost**: Secret management and monitoring tools have licensing costs

## Code Samples

\`\`\`csharp
// 1. API Gateway Authentication Configuration (YARP)
public static class Program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        // Add authentication
        builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(options =>
            {
                options.Authority = "https://your-identity-server.com";
                options.Audience = "api-gateway";
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidateLifetime = true,
                    ValidateIssuerSigningKey = true
                };
            });

        // Add rate limiting
        builder.Services.AddRateLimiter(options =>
        {
            options.AddFixedWindowLimiter("fixed", opt =>
            {
                opt.Window = TimeSpan.FromMinutes(1);
                opt.PermitLimit = 100;
            });
        });

        builder.Services.AddReverseProxy()
            .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"));

        var app = builder.Build();

        app.UseRateLimiter();
        app.UseAuthentication();
        app.UseAuthorization();
        app.MapReverseProxy();

        app.Run();
    }
}

// 2. Service-to-Service Authentication using JWT
public class ServiceTokenProvider
{
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _config;
    private string? _cachedToken;
    private DateTime _tokenExpiry;

    public ServiceTokenProvider(HttpClient httpClient, IConfiguration config)
    {
        _httpClient = httpClient;
        _config = config;
    }

    public async Task<string> GetServiceTokenAsync()
    {
        if (_cachedToken != null && DateTime.UtcNow < _tokenExpiry)
            return _cachedToken;

        var clientId = _config["ServiceAuth:ClientId"];
        var clientSecret = _config["ServiceAuth:ClientSecret"]; // From Key Vault
        var tokenEndpoint = _config["ServiceAuth:TokenEndpoint"];

        var requestBody = new Dictionary<string, string>
        {
            { "client_id", clientId },
            { "client_secret", clientSecret },
            { "grant_type", "client_credentials" },
            { "scope", "orders.read orders.write" }
        };

        var response = await _httpClient.PostAsync(tokenEndpoint, new FormUrlEncodedContent(requestBody));
        response.EnsureSuccessStatusCode();

        var tokenResponse = await response.Content.ReadFromJsonAsync<TokenResponse>();
        _cachedToken = tokenResponse.AccessToken;
        _tokenExpiry = DateTime.UtcNow.AddSeconds(tokenResponse.ExpiresIn - 60);

        return _cachedToken;
    }
}

// 3. Secret Management with Azure Key Vault
public static IHostBuilder CreateHostBuilder(string[] args) =>
    Host.CreateDefaultBuilder(args)
        .ConfigureAppConfiguration((context, config) =>
        {
            var builtConfig = config.Build();
            var keyVaultEndpoint = builtConfig["KeyVault:Endpoint"];

            if (!string.IsNullOrEmpty(keyVaultEndpoint))
            {
                var credential = new DefaultAzureCredential();
                config.AddAzureKeyVault(new Uri(keyVaultEndpoint), credential);
            }
        })
        .ConfigureWebHostDefaults(webBuilder =>
        {
            webBuilder.UseStartup<Startup>();
        });

// 4. Authorization Policy
public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddAuthorization(options =>
        {
            options.AddPolicy("AdminOnly", policy =>
                policy.RequireClaim("role", "admin"));

            options.AddPolicy("OrderAccess", policy =>
                policy.RequireAssertion(context =>
                    context.User.HasClaim("scope", "orders.read") ||
                    context.User.HasClaim("scope", "orders.write")));
        });

        services.AddControllers();
    }
}

// 5. Secure HttpClient for Service Communication
public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddSecureHttpClient<TClient>(
        this IServiceCollection services,
        string baseAddress)
        where TClient : class
    {
        services.AddHttpClient<TClient>(client =>
        {
            client.BaseAddress = new Uri(baseAddress);
            client.DefaultRequestHeaders.Add("User-Agent", "OrderService/1.0");
        })
        .AddHttpMessageHandler<ServiceAuthenticationHandler>()
        .AddPolicyHandler(GetRetryPolicy())
        .AddPolicyHandler(GetCircuitBreakerPolicy());

        return services;
    }

    private static IAsyncPolicy<HttpResponseMessage> GetRetryPolicy()
    {
        return HttpPolicyExtensions
            .HandleTransientHttpError()
            .WaitAndRetryAsync(3, retryAttempt =>
                TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)));
    }

    private static IAsyncPolicy<HttpResponseMessage> GetCircuitBreakerPolicy()
    {
        return HttpPolicyExtensions
            .HandleTransientHttpError()
            .CircuitBreakerAsync(5, TimeSpan.FromSeconds(30));
    }
}

// 6. Authentication Handler for Service-to-Service Calls
public class ServiceAuthenticationHandler : DelegatingHandler
{
    private readonly ServiceTokenProvider _tokenProvider;

    public ServiceAuthenticationHandler(ServiceTokenProvider tokenProvider)
    {
        _tokenProvider = tokenProvider;
    }

    protected override async Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request,
        CancellationToken cancellationToken)
    {
        var token = await _tokenProvider.GetServiceTokenAsync();
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);

        return await base.SendAsync(request, cancellationToken);
    }
}
\`\`\`
`,
    category: 'Security',
    tags: ['Microservices', 'Security', 'API Gateway'],
    author: 'Carol Davis',
    createdDate: '2024-01-12T13:00:00Z',
    updatedDate: '2024-01-16T10:20:00Z',
    voteCount: 29,
    status: 'published',
    isTrending: true,
  },
  {
    id: '6',
    title: 'Performance Optimization with AI Analysis',
    slug: 'performance-optimization-ai',
    shortDescription: 'Use AI tools to identify performance bottlenecks, optimize database queries, and improve application response times.',
    fullContent: `## Overview

Performance optimization using AI combines traditional profiling tools with AI-powered code analysis to identify bottlenecks, suggest optimizations, and improve application responsiveness. This approach leverages AI to analyze profiler output, database execution plans, and code patterns to recommend data-driven optimizations.

## Problem Statement

Performance bottlenecks are often hidden in complex codebases and difficult to identify without extensive profiling. Manual analysis of profiler data is time-consuming. Database query optimization requires deep SQL knowledge. Memory leaks are hard to detect. Teams lack expertise to interpret profiler results and implement optimal solutions. Performance issues often discovered late in development or production.

## Proposed Solution

Combine profiling tools (dotTrace, BenchmarkDotNet, SQL Server Profiler) with AI analysis of results. Use AI to interpret profiler data, analyze database execution plans, identify algorithmic inefficiencies, suggest caching strategies, detect memory leaks, and recommend code optimizations. Implement continuous performance testing in CI/CD pipeline.

## AI Prompt Examples

\`\`\`
**Analyze Profiler Output**

I ran a performance profiler and found these hot paths taking 80% of execution time:
[Paste profiler snapshot or method timings]

Analyze this data and:
1. Identify the root cause of slow performance
2. Suggest specific code optimizations
3. Estimate performance improvement for each suggestion
4. Provide refactored code examples
\`\`\`

\`\`\`
**Database Query Optimization**

This SQL query is taking 3 seconds to execute on a table with 1 million rows:

[Paste SQL query and execution plan]

Table schema:
[Paste schema]

Existing indexes:
[List indexes]

Analyze and suggest:
- Missing indexes
- Query rewrite options
- Potential for query splitting
- Caching opportunities
\`\`\`

\`\`\`
**Algorithm Complexity Analysis**

Review this code for algorithm complexity issues:

[Paste code]

Identify:
1. Current Big O complexity for time and space
2. Nested loops or repeated operations
3. Inefficient data structures
4. Opportunities for optimization
5. Provide optimized implementation with better complexity
\`\`\`

\`\`\`
**Memory Leak Detection**

I'm seeing increasing memory usage in production. Here's the heap snapshot:
[Paste memory profiler data or object retention graph]

Analyze for:
- Objects not being garbage collected
- Event handler leaks
- Static collection growth
- IDisposable not called
- Provide fix recommendations
\`\`\`

## Implementation Steps

1. **Profile the Application**: Use dotTrace, Visual Studio Profiler, or BenchmarkDotNet to identify slow methods and memory hotspots.

2. **Capture Baseline Metrics**: Record current performance metrics (response time, throughput, memory usage) for comparison.

3. **AI Analysis of Profiler Data**: Feed profiler output to AI for interpretation and optimization suggestions.

4. **Prioritize Optimizations**: Focus on hotspots with highest impact (80/20 rule - optimize 20% of code causing 80% of issues).

5. **Implement Database Optimizations**: Analyze execution plans, add indexes, rewrite queries, implement caching based on AI recommendations.

6. **Optimize Algorithms**: Replace inefficient algorithms (N² loops) with better alternatives suggested by AI.

7. **Benchmark Changes**: Use BenchmarkDotNet to measure actual performance improvements.

8. **Monitor Production**: Implement APM (Application Performance Monitoring) to track real-world performance.

## Trade-offs

### Pros
- **Data-Driven**: Optimizations based on actual profiler data, not guesses
- **Learning Tool**: AI explanations help developers understand performance concepts
- **Comprehensive**: AI can analyze multiple performance aspects simultaneously
- **Time-Saving**: Faster than manual analysis of profiler output
- **Best Practices**: AI suggests industry-standard optimization techniques

### Cons
- **Tool Dependency**: Requires profiling tools and AI access
- **Context Limitations**: AI may not understand specific business requirements
- **Over-Optimization**: Risk of premature optimization on non-critical paths
- **Validation Needed**: Must benchmark to confirm AI suggestions actually improve performance
- **Cost**: Profiling tools and AI API usage have costs

## Code Samples

\`\`\`csharp
// BEFORE: Inefficient N+1 query problem
public async Task<List<OrderDto>> GetCustomerOrdersAsync(Guid customerId)
{
    var orders = await _context.Orders
        .Where(o => o.CustomerId == customerId)
        .ToListAsync();

    var orderDtos = new List<OrderDto>();
    foreach (var order in orders)
    {
        // N+1 problem: separate query for each order's items
        var items = await _context.OrderItems
            .Where(i => i.OrderId == order.Id)
            .ToListAsync();

        orderDtos.Add(new OrderDto
        {
            Id = order.Id,
            Items = items.Select(i => new OrderItemDto { ... }).ToList()
        });
    }

    return orderDtos;
}

// AFTER: Optimized with eager loading
public async Task<List<OrderDto>> GetCustomerOrdersAsync(Guid customerId)
{
    var orders = await _context.Orders
        .Include(o => o.Items)  // Eager load items in single query
        .ThenInclude(i => i.Product)  // Include product details
        .Where(o => o.CustomerId == customerId)
        .AsNoTracking()  // Faster for read-only scenarios
        .ToListAsync();

    return orders.Select(o => new OrderDto
    {
        Id = o.Id,
        Items = o.Items.Select(i => new OrderItemDto
        {
            ProductName = i.Product.Name,
            Quantity = i.Quantity,
            Price = i.Price
        }).ToList()
    }).ToList();
}

// BEFORE: Inefficient string concatenation in loop
public string GenerateReport(List<Transaction> transactions)
{
    string report = "";
    foreach (var transaction in transactions)
    {
        report += $"{transaction.Date}, {transaction.Amount}, {transaction.Description}\\n";
    }
    return report;
}

// AFTER: Using StringBuilder for O(n) instead of O(n²)
public string GenerateReport(List<Transaction> transactions)
{
    var sb = new StringBuilder(transactions.Count * 100);  // Pre-allocate capacity
    foreach (var transaction in transactions)
    {
        sb.AppendLine($"{transaction.Date:yyyy-MM-dd}, {transaction.Amount:C}, {transaction.Description}");
    }
    return sb.ToString();
}

// BEFORE: Inefficient LINQ with multiple iterations
public decimal GetAverageOrderValue(List<Order> orders)
{
    var totalOrders = orders.Count();
    var totalRevenue = orders.Sum(o => o.Total);
    var avgValue = totalRevenue / totalOrders;
    return avgValue;
}

// AFTER: Single pass aggregation
public decimal GetAverageOrderValue(List<Order> orders)
{
    if (orders.Count == 0) return 0;
    return orders.Average(o => o.Total);  // Single iteration
}

// Caching implementation for expensive operations
public class ProductService
{
    private readonly IMemoryCache _cache;
    private readonly IProductRepository _repository;

    public async Task<Product> GetProductAsync(Guid productId)
    {
        return await _cache.GetOrCreateAsync($"product-{productId}", async entry =>
        {
            entry.SlidingExpiration = TimeSpan.FromMinutes(10);
            entry.AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(1);
            return await _repository.GetByIdAsync(productId);
        });
    }
}

// Benchmark using BenchmarkDotNet
[MemoryDiagnoser]
public class StringConcatenationBenchmark
{
    private List<string> _items;

    [GlobalSetup]
    public void Setup()
    {
        _items = Enumerable.Range(1, 1000).Select(i => $"Item {i}").ToList();
    }

    [Benchmark]
    public string UsingStringConcatenation()
    {
        string result = "";
        foreach (var item in _items)
            result += item + ", ";
        return result;
    }

    [Benchmark]
    public string UsingStringBuilder()
    {
        var sb = new StringBuilder();
        foreach (var item in _items)
            sb.Append(item).Append(", ");
        return sb.ToString();
    }

    [Benchmark]
    public string UsingStringJoin()
    {
        return string.Join(", ", _items);
    }
}

// Results show String.Join is 100x faster than string concatenation
\`\`\`
`,
    category: 'Performance',
    tags: ['Performance', 'Optimization', 'AI Tools'],
    author: 'David Lee',
    createdDate: '2024-01-20T15:00:00Z',
    updatedDate: '2024-01-20T15:00:00Z',
    voteCount: 23,
    status: 'published',
  },
]

export function getFeaturedPatterns(): Pattern[] {
  return mockPatterns.filter(p => p.isFeatured && p.status === 'published')
}

export function getTrendingPatterns(): Pattern[] {
  return mockPatterns.filter(p => p.isTrending && p.status === 'published')
}

export function getAllCategories(): string[] {
  return Array.from(new Set(mockPatterns.map(p => p.category)))
}

export function getPatternStats() {
  return {
    totalPatterns: mockPatterns.filter(p => p.status === 'published').length,
    totalCategories: getAllCategories().length,
    totalContributors: '15+',
  }
}

export function getPatternBySlug(slug: string): Pattern | null {
  return mockPatterns.find(p => p.slug === slug && p.status === 'published') || null
}

export function getPublishedPatterns(): Pattern[] {
  return mockPatterns.filter(p => p.status === 'published')
}
