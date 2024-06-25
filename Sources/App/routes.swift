import Fluent
import Vapor


func routes(_ app: Application) throws {
    let baseGroup = app.grouped(["api", "v1"])

    let tokenProtected = baseGroup.grouped(UserToken.authenticator())

    try tokenProtected.register(collection: RegisterController())
    try tokenProtected.register(collection: ImageController())
    try tokenProtected.register(collection: PairController())
}
