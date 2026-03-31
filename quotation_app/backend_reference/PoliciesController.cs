// ============================================================================
// PoliciesController.cs — C# Web API Controller for Policy CRUD
// ============================================================================
// THIS FILE IS A REFERENCE — it shows what the C# backend looks like.
// You'd put this in your .NET 8 Web API project.
//
// WHAT IS A CONTROLLER?
//   In a restaurant analogy:
//   - The Flutter app is the CUSTOMER (places orders)
//   - The Controller is the WAITER (receives orders, passes them to the kitchen)
//   - The Database is the KITCHEN (stores and retrieves the actual data)
//
// HOW IT CONNECTS TO FLUTTER:
//   Flutter's Dio sends HTTP requests → they arrive at this Controller
//   → the Controller talks to the database → sends data back to Flutter
//
// HTTP METHODS:
//   GET    /api/policies       → GetAll()      → Returns all policies
//   GET    /api/policies/{id}  → GetById(id)   → Returns one policy
//   POST   /api/policies       → Create(policy)→ Creates a new policy
//   PUT    /api/policies/{id}  → Update(policy)→ Updates existing policy
//   DELETE /api/policies/{id}  → Delete(id)    → Deletes a policy
//
// TO RUN THIS:
//   1. Create a new .NET 8 Web API project:
//      dotnet new webapi -n PolicyApi
//   2. Add Entity Framework:
//      dotnet add package Microsoft.EntityFrameworkCore.SqlServer
//   3. Copy this file to the Controllers folder
//   4. Create the Policy model and DbContext (shown below)
//   5. Run migrations:
//      dotnet ef migrations add InitialCreate
//      dotnet ef database update
//   6. Run the API:
//      dotnet run
// ============================================================================

using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace PolicyApi.Controllers;

// ═══════════════════════════════════════════════════════════════════
// STEP 1: THE DATA MODEL (what a Policy looks like in C#)
// ═══════════════════════════════════════════════════════════════════
// This is the C# equivalent of our Dart PolicyModel.
// Entity Framework uses this to create the database table automatically.

/// <summary>
/// Represents an insurance policy in the database.
/// Each property becomes a column in the SQL table.
/// </summary>
public class Policy
{
    /// <summary>
    /// Primary key — auto-generated unique identifier.
    /// In SQL, this creates an "Id" column with IDENTITY (auto-increment).
    /// </summary>
    public Guid Id { get; set; } = Guid.NewGuid();

    /// <summary>
    /// The company buying the insurance.
    /// [Required] means this column cannot be NULL in the database.
    /// [MaxLength] limits the string length (prevents storing a novel in here!).
    /// </summary>
    [Required]
    [MaxLength(200)]
    public string SponsorName { get; set; } = string.Empty;

    /// <summary>
    /// Unique sponsor identifier code (like a customer number).
    /// </summary>
    [Required]
    [MaxLength(20)]
    public string SponsorNumber { get; set; } = string.Empty;

    /// <summary>
    /// How many people are covered under this policy.
    /// </summary>
    public int MemberCount { get; set; }

    /// <summary>
    /// Total yearly cost in SAR (Saudi Riyals).
    /// We use decimal for money — never use float/double for financial calculations!
    /// (Floats can have rounding errors like 0.1 + 0.2 = 0.30000000000000004)
    /// </summary>
    [Column(TypeName = "decimal(18,2)")]
    public decimal TotalPremium { get; set; }

    /// <summary>
    /// When does coverage start?
    /// </summary>
    public DateTime EffectiveDate { get; set; }

    /// <summary>
    /// Current status: draft, pending, approved, rejected, expired
    /// </summary>
    [MaxLength(20)]
    public string Status { get; set; } = "draft";

    /// <summary>
    /// When was this record created? Auto-set to "now" when created.
    /// </summary>
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// Optional notes — can be null.
    /// The ? after string means "this can be null" (nullable).
    /// </summary>
    [MaxLength(500)]
    public string? Notes { get; set; }
}

// ═══════════════════════════════════════════════════════════════════
// STEP 2: THE DATABASE CONTEXT (the "bridge" between C# and SQL)
// ═══════════════════════════════════════════════════════════════════
// DbContext is like a "translator" between your C# code and the database.
// When you say _context.Policies.Add(policy), it generates:
//   INSERT INTO Policies (SponsorName, ...) VALUES ('Acme Corp', ...)

/// <summary>
/// Database context — tells Entity Framework about our tables.
/// </summary>
public class PolicyDbContext : DbContext
{
    public PolicyDbContext(DbContextOptions<PolicyDbContext> options) 
        : base(options) { }

    /// <summary>
    /// This creates a "Policies" table in the database.
    /// Each Policy object = one row in the table.
    /// </summary>
    public DbSet<Policy> Policies { get; set; }
}

// ═══════════════════════════════════════════════════════════════════
// STEP 3: THE CONTROLLER (handles HTTP requests from Flutter)
// ═══════════════════════════════════════════════════════════════════
// [ApiController] tells ASP.NET "this is a REST API controller"
// [Route("api/[controller]")] means the URL will be /api/policies
//   (it uses the class name minus "Controller")

[ApiController]
[Route("api/[controller]")]
public class PoliciesController : ControllerBase
{
    // ── Dependency Injection ──
    // The database context is "injected" by the framework.
    // Think of it as the framework saying "here's your database connection."
    private readonly PolicyDbContext _context;

    public PoliciesController(PolicyDbContext context)
    {
        _context = context;
    }

    // ── READ ALL (GET /api/policies) ─────────────────────────────────
    /// <summary>
    /// Returns ALL policies from the database.
    /// 
    /// FLUTTER CALLS THIS WITH:
    ///   final response = await _dio.get('/policies');
    /// 
    /// SQL EQUIVALENT:
    ///   SELECT * FROM Policies ORDER BY CreatedAt DESC
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Policy>>> GetAll()
    {
        // .ToListAsync() fetches all rows from the Policies table
        // .OrderByDescending() sorts by newest first
        var policies = await _context.Policies
            .OrderByDescending(p => p.CreatedAt)
            .ToListAsync();
        
        // Return 200 OK with the data
        return Ok(policies);
    }

    // ── READ ONE (GET /api/policies/{id}) ────────────────────────────
    /// <summary>
    /// Returns ONE specific policy by its ID.
    /// 
    /// FLUTTER CALLS THIS WITH:
    ///   final response = await _dio.get('/policies/$id');
    /// 
    /// SQL EQUIVALENT:
    ///   SELECT * FROM Policies WHERE Id = @id
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<Policy>> GetById(Guid id)
    {
        // FindAsync searches by primary key (the Id column)
        var policy = await _context.Policies.FindAsync(id);

        // If no policy found with that ID, return 404 Not Found
        if (policy == null)
        {
            return NotFound(new { message = $"Policy with ID {id} not found." });
        }

        return Ok(policy);
    }

    // ── CREATE (POST /api/policies) ──────────────────────────────────
    /// <summary>
    /// Creates a new policy in the database.
    /// 
    /// FLUTTER CALLS THIS WITH:
    ///   final response = await _dio.post('/policies', data: policy.toJson());
    /// 
    /// SQL EQUIVALENT:
    ///   INSERT INTO Policies (Id, SponsorName, ...) VALUES (newid(), 'Acme Corp', ...)
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<Policy>> Create([FromBody] Policy policy)
    {
        // Generate a new ID and set the creation timestamp
        policy.Id = Guid.NewGuid();
        policy.CreatedAt = DateTime.UtcNow;

        // Add to the database (queued, not saved yet)
        _context.Policies.Add(policy);

        // SaveChangesAsync actually writes to the database
        // (like clicking "Save" in Excel)
        await _context.SaveChangesAsync();

        // Return 201 Created with the new policy (including its new ID)
        // CreatedAtAction also sets the Location header to /api/policies/{id}
        return CreatedAtAction(nameof(GetById), new { id = policy.Id }, policy);
    }

    // ── UPDATE (PUT /api/policies/{id}) ──────────────────────────────
    /// <summary>
    /// Updates an existing policy.
    /// 
    /// FLUTTER CALLS THIS WITH:
    ///   final response = await _dio.put('/policies/$id', data: policy.toJson());
    /// 
    /// SQL EQUIVALENT:
    ///   UPDATE Policies SET SponsorName = 'New Name', ... WHERE Id = @id
    /// </summary>
    [HttpPut("{id}")]
    public async Task<ActionResult<Policy>> Update(Guid id, [FromBody] Policy policy)
    {
        // First, check if the policy exists
        var existing = await _context.Policies.FindAsync(id);
        if (existing == null)
        {
            return NotFound(new { message = $"Policy with ID {id} not found." });
        }

        // Update the fields (copy new values onto the existing record)
        existing.SponsorName = policy.SponsorName;
        existing.SponsorNumber = policy.SponsorNumber;
        existing.MemberCount = policy.MemberCount;
        existing.TotalPremium = policy.TotalPremium;
        existing.EffectiveDate = policy.EffectiveDate;
        existing.Status = policy.Status;
        existing.Notes = policy.Notes;
        // Note: We do NOT update CreatedAt — it should stay as the original creation date

        // Save changes to the database
        await _context.SaveChangesAsync();

        return Ok(existing);
    }

    // ── DELETE (DELETE /api/policies/{id}) ────────────────────────────
    /// <summary>
    /// Deletes a policy from the database.
    /// 
    /// FLUTTER CALLS THIS WITH:
    ///   await _dio.delete('/policies/$id');
    /// 
    /// SQL EQUIVALENT:
    ///   DELETE FROM Policies WHERE Id = @id
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<ActionResult> Delete(Guid id)
    {
        var policy = await _context.Policies.FindAsync(id);
        if (policy == null)
        {
            return NotFound(new { message = $"Policy with ID {id} not found." });
        }

        // Remove from the database
        _context.Policies.Remove(policy);
        await _context.SaveChangesAsync();

        // Return 204 No Content (success, but no data to return)
        return NoContent();
    }
}

// ═══════════════════════════════════════════════════════════════════
// STEP 4: PROGRAM.CS SETUP (wire everything together)
// ═══════════════════════════════════════════════════════════════════
// Put this in your Program.cs to set up the database and controllers.
//
// var builder = WebApplication.CreateBuilder(args);
//
// // Add database connection
// builder.Services.AddDbContext<PolicyDbContext>(options =>
//     options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));
//
// // Add controllers
// builder.Services.AddControllers();
//
// // Add Swagger (API documentation)
// builder.Services.AddEndpointsApiExplorer();
// builder.Services.AddSwaggerGen();
//
// // Allow Flutter app to call the API (CORS)
// builder.Services.AddCors(options =>
// {
//     options.AddDefaultPolicy(policy =>
//         policy.AllowAnyOrigin()
//               .AllowAnyMethod()
//               .AllowAnyHeader());
// });
//
// var app = builder.Build();
//
// app.UseCors();
// app.UseSwagger();
// app.UseSwaggerUI();
// app.MapControllers();
//
// app.Run();
//
// ═══════════════════════════════════════════════════════════════════
// appsettings.json:
// {
//   "ConnectionStrings": {
//     "DefaultConnection": "Server=localhost;Database=PolicyDb;Trusted_Connection=true;TrustServerCertificate=true;"
//   }
// }
// ═══════════════════════════════════════════════════════════════════
