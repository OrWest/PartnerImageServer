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
        routes.get("me", use: getMe)
    }

    private func register(req: Request) async throws -> RegisteredUser {
        if let registeredUser = try? await getRegisteredUser(req: req) {
            return registeredUser
        }

        let newUser = Partner()
        try await newUser.save(on: req.db)
        let token = try newUser.generateToken()
        try await token.save(on: req.db)

        return RegisteredUser(
            userId: String(token.$user.id),
            token: token.value
        )

    }

    private func getMe(req: Request) async throws -> RegisteredUser {
        try await getRegisteredUser(req: req)
    }

    private func getRegisteredUser(req: Request) async throws -> RegisteredUser {
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
