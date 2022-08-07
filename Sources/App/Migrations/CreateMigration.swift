import Fluent

struct CreateMigration: AsyncMigration {
    func prepare(on database: Database) async throws {

        // Partnerships
        try await database.schema("partnerships")
            .id()
            .field("created_at", .datetime)
            .field("deleted_at", .datetime)
            .create()

        // Partners
        try await database.schema("partners")
            .field("id", .int, .identifier(auto: true))
            .field("token", .string, .required)
            .field("partnership_id", .uuid, .references("partnerships", "id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "token")
            .create()

        // Images
        try await database.schema("images")
            .id()
            .field("name", .string, .required)
            .field("creator_id", .int, .required, .references("partners", "id"))
            .field("presenter_id", .int, .required, .references("partners", "id"))
            .field("partnership_id", .uuid, .required, .references("partnerships", "id"))
            .field("created_at", .datetime)
            .field("deleted_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("partnerships").delete()
        try await database.schema("partners").delete()
        try await database.schema("images").delete()
    }
}
