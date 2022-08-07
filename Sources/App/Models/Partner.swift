//
//  Partner.swift
//  
//
//  Created by Aleksandr Motarykin on 2022-08-06.
//

import Vapor
import Fluent

final class Partner: Model, Content {
    static let schema: String = "partners"

    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @Field(key: "token")
    var token: String

    @Parent(key: "partnership_id")
    var partnership: Partnership

    @Children(for: \.$creator)
    var createdImages: [Image]

    @Children(for: \.$presenter)
    var presentedImages: [Image]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(id: Int? = nil, token: String) {
        self.id = id
        self.token = token
    }
}
