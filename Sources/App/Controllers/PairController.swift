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
        routes.group("partner") { partner in
            partner.post("pair", ":pairCode", use: pair)
            partner.post("invite", use: generateInviteCode)
            partner.get(use: getPartner)
        }
    }

    private func pair(req: Request) async throws -> HTTPStatus {
        let requestingUser = try req.auth.require(Partner.self)
        guard let pairCode = req.parameters.get("pairCode") else {
            throw Abort(.badRequest, reason: "Pair code is required.")
        }

        guard let partnership = 
            try await Partnership.query(on: req.db)
                .filter(\.$pairCode == pairCode)
                .first()
        else {
            throw Abort(.notFound, reason: "Invite code is not valid. Generate new one.")
        }

        partnership.pairCode = nil // To not accept pair again
        try await partnership.update(on: req.db)
        try await addPartnership(partnership, to: requestingUser, db: req.db)
        req.logger.info("Partnership finalized (\(partnership.id!)).")

        return .ok
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

    private func generateInviteCode(req: Request) async throws -> Response {
        let requestingUser = try req.auth.require(Partner.self)
        let partnership = Partnership()
        let pairCode = PairCodeGenerator.generateCode()
        partnership.pairCode = pairCode
        try await partnership.create(on: req.db)

        try await addPartnership(partnership, to: requestingUser, db: req.db)
        req.logger.info("Partnership created (\(partnership.id!)). Invite code: \(pairCode)")

        return .init(status: .created, body: .init(string: pairCode))
    }
}
