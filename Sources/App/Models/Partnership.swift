//
//  Partnership.swift
//  
//
//  Created by Aleksandr Motarykin on 2022-08-06.
//

import Vapor
import Fluent

final class Partnership: Model, Content {
    static let schema: String = "partnerships"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "pair_code")
    var pairCode: String?

    @Children(for: \.$partnership)
    var partners: [Partner]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init() { }

    func getPartner(me: Partner, db: Database) async throws -> Partner {
        try await self.$partners.load(on: db)

        if partners[0].id == me.id {
            return partners[1]
        } else {
            return partners[0]
        }
    }
}

