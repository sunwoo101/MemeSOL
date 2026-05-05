using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace backend.Migrations
{
    /// <inheritdoc />
    public partial class SyncModel : Migration
    {
        /// <inheritdoc />
        // xmin is a PostgreSQL system column — it already exists on every row.
        // No schema change needed; this migration exists only to satisfy EF Core's model snapshot.
        protected override void Up(MigrationBuilder migrationBuilder) { }

        protected override void Down(MigrationBuilder migrationBuilder) { }
    }
}
