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
    private static let tokenSize = 32

    func boot(routes: RoutesBuilder) throws {
        routes.post("register", use: register)
    }

    private func register(req: Request) async throws -> RegisteredUser {
        let token = RegisterController.generateToken()
        let newUser = Partner(token: token)
        try await newUser.save(on: req.db)

        return RegisteredUser(
            userId: String(try newUser.requireID()),
            token: newUser.token
        )

    }

    private static func generateToken() -> String {
        return [UInt8].random(count: tokenSize).base64
    }

}
