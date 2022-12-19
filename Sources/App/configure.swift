import Fluent
import FluentPostgresDriver
import Vapor
import JWT

fileprivate enum ConfigureError: String, Error {
    case environmentNotSet = "No JWT_SIGNING_SECRET set in the environment"
}

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    configureDatabase(on: app)
    try databaseMigrations(on: app)
    
    try configureJWT(on: app)
    
    try routes(app)
}

func configureDatabase(on app: Application) {
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "mcritz",
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: Environment.get("DATABASE_NAME") ?? "mcritz"
    ), as: .psql)
}

func databaseMigrations(on app: Application) throws {
    app.migrations.add(CreateTodo())
    app.migrations.add(CreateInterestGroup())
    app.migrations.add(User.Migration())
    app.migrations.add(Tag.Migration())
    app.migrations.add(UserTag.Migration())
    app.migrations.add(AddSuperUser())
    
    #if DEBUG
    print("DEBUG: Automigrate Start")
    try app.autoMigrate().wait()
    print("DEBUG: Automigrate Done")
    #endif
}

func configureJWT(on app: Application) throws {
    guard let secret = Environment.get("JWT_SIGNING_SECRET") else {
        throw ConfigureError.environmentNotSet
    }
    app.jwt.signers.use(.hs256(key: secret))
}
