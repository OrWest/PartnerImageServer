//
//  ImageController.swift
//  
//
//  Created by Aleksandr Motarykin on 2022-08-07.
//
import Fluent
import Vapor

class ImageController: RouteCollection {
    private let imageDirName = "tmp/"

    func boot(routes: RoutesBuilder) throws {
        routes.post("new", use: uploadNewImage(req:))
    }

    private func uploadNewImage(req: Request) async throws -> Response {
        let file = try req.content.decode(File.self)
        guard let ext = file.extension, ["png", "jpg"].contains(ext) else {
            throw Abort(.unsupportedMediaType, reason: "Only png and jpg files supported.")
        }

        let path = req.application.directory.workingDirectory + imageDirName + UUID().uuidString + "." + ext

        try await req.fileio.writeFile(file.data, at: path)

        req.logger.info("Image saved: \(path)")

        return .init(status: .accepted)
    }
}
