//
//  ImageController.swift
//  
//
//  Created by Aleksandr Motarykin on 2022-08-07.
//
import Fluent
import Vapor

struct ImageDTO: Content {
    let imageURL: String
}

class ImageController: RouteCollection {
    private let imageDirName = "tmp/"

    func boot(routes: RoutesBuilder) throws {
        routes.post("new", use: uploadNewImage)
        routes.get("actual", use: getActualImage)
    }

    private func uploadNewImage(req: Request) async throws -> Response {
        let file = try req.content.decode(File.self)
        guard let ext = file.extension, ["png", "jpg"].contains(ext) else {
            throw Abort(.unsupportedMediaType, reason: "Only png and jpg files supported.")
        }

        let name = UUID().uuidString + "." + ext
        let path = req.application.directory.workingDirectory + imageDirName + name

        try await req.fileio.writeFile(file.data, at: path)

        req.logger.info("Image saved: \(path)")

        let requestingUser = try req.auth.require(Partner.self)
        try await requestingUser.$partnership.load(on: req.db)

        guard let partnerShip = requestingUser.partnership else {
            throw Abort(.notFound, reason: "No partnership related to this user (\(requestingUser.id!))")
        }

        let partner = try await partnerShip.getPartner(me: requestingUser, db: req.db)
        let image = Image(name: name)
        image.$creator.id = requestingUser.id!
        image.$presenter.id = partner.id!
        image.$partnership.id = partnerShip.id!
        try await image.create(on: req.db)

        return .init(status: .accepted)
    }

    private func getActualImage(req: Request) async throws -> Response {
        let requestingUser = try req.auth.require(Partner.self)
        try await requestingUser.$partnership.load(on: req.db)

        guard let partnerShip = requestingUser.partnership else {
            throw Abort(.notFound, reason: "No partnership related to this user (\(requestingUser.id!))")
        }

        guard let image = try await Image.query(on: req.db)
            .filter(\.$partnership.$id == partnerShip.id!)
            .filter(\.$presenter.$id == requestingUser.id!)
            .sort(\.$createdAt, .descending)
            .first() else {

            return Response(status: .ok)
        }

        let url = req.application.directory.workingDirectory + imageDirName + image.name
        let buffer = try await req.fileio.collectFile(at: url)
        return Response(status: .ok, body: .init(data: Data(buffer: buffer)))
    }
}
