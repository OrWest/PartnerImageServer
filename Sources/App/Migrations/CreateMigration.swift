import Fluent

struct CreateMigration: AsyncMigration {
    func prepare(on database: Database) async throws {

        // Partnerships
        try await database.schema("partnerships")
            .id()
            .field("pair_code", .string)
            .field("created_at", .datetime)
            .field("deleted_at", .datetime)
            .create()

        // Partners
        try await database.schema("partners")
            .field("id", .int, .identifier(auto: true))
            .field("partnership_id", .uuid, .references("partnerships", "id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()

        // Token
        try await database.schema("user_tokens")
            .id()
            .field("value", .string, .required)
            .field("user_id", .int, .required, .references("partners", "id"))
            .field("created_at", .datetime)
            .field("deleted_at", .datetime)
            .unique(on: "value")
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
        try await database.schema("user_tokens").delete()
    }
}
