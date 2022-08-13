//
//  PairController.swift
//  
//
//  Created by Aleksandr Motarykin on 2022-08-08.
//
import Fluent
import Vapor

class PairController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.post("pair", ":userID", use: pair)
        routes.get("partner", use: getPartner)
    }

    private func pair(req: Request) async throws -> Response {
        let requestingUser = try req.auth.require(Partner.self)
        guard let partnerIdString = req.parameters.get("userID"), let partnerId = Int(partnerIdString) else {
            throw Abort(.badRequest, reason: "UserId is required.")
        }

        guard let partner = try await Partner.find(partnerId, on: req.db) else {
            throw Abort(.badRequest, reason: "Unknown partner user: \(partnerId)")
        }

        let partnerShip = Partnership()
        try await partnerShip.create(on: req.db)

        try await addPartnership(partnerShip, to: requestingUser, db: req.db)
        try await addPartnership(partnerShip, to: partner, db: req.db)

        return .init(status: .created)
    }

    private func addPartnership(_ partnerShip: Partnership, to partner: Partner, db: Database) async throws {
        partner.$partnership.id = partnerShip.id
        try await partner.update(on: db)
    }

    private func getPartner(req: Request) async throws -> String {
        let requestingUser = try req.auth.require(Partner.self)
        try await requestingUser.$partnership.load(on: req.db)

        guard let partnerShip = requestingUser.partnership else {
            throw Abort(.notFound, reason: "No partnership related to this user (\(requestingUser.id!))")
        }

        let partner = try await partnerShip.getPartner(me: requestingUser, db: req.db)
        req.logger.info("Partnership exists: \(partnerShip.id!). \(requestingUser.id!)<>\(partner.id!)")

        return String(partner.id!)
    }
}
