//
//  File.swift
//  
//
//  Created by Aleksandr Motarykin on 2022-08-06.
//
import Fluent
import Vapor

final class Image: Model, Content {
    static let schema = "images"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Parent(key: "creator_id")
    var creator: Partner

    @Parent(key: "presenter_id")
    var presenter: Partner

    @Parent(key: "partnership_id")
    var partnership: Partnership

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
