import Fluent
import Vapor


func routes(_ app: Application) throws {
    let baseGroup = app.grouped(["api", "v1"])

    try baseGroup.register(collection: RegisterController())
    try baseGroup.register(collection: ImageController())
    try baseGroup.register(collection: PairController())
}
