//
//  RegisterController.swift
//  
//
//  Created by Aleksandr Motarykin on 2022-08-06.
//
import Fluent
import Vapor

struct RegisteredUser: Content {
    var userId: String
    var token: String
}

struct RegisterController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.post("register", use: register)

        let tokenProtected = routes.grouped(UserToken.authenticator())
        tokenProtected.get("me") { req -> RegisteredUser in
            let user = try req.auth.require(Partner.self)
            guard let userToken = try await UserToken.query(on: req.db)
                .filter(\.$user.$id == user.id!)
                .first() else {
                throw Abort(.internalServerError)
            }

            return RegisteredUser(
                userId: String(userToken.$user.id),
                token: userToken.value
            )
        }

    }

    private func register(req: Request) async throws -> RegisteredUser {
        let newUser = Partner()
        try await newUser.save(on: req.db)
        let token = try newUser.generateToken()
        try await token.save(on: req.db)

        return RegisteredUser(
            userId: String(token.$user.id),
            token: token.value
        )

    }
}
