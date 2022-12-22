import Fluent
import FluentPostgresDriver
#if DEBUG
import FluentSQLiteDriver
#endif
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
    if app.environment.name != Environment.testing.name {
        guard let username = Environment.get("DATABASE_USERNAME"),
              let database = Environment.get("DATABASE_NAME") else {
            preconditionFailure("""
            Environment values are not set
            """)
        }
        app.databases.use(.postgres(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
            username: username,
            password: Environment.get("DATABASE_PASSWORD") ?? "",
            database: database
        ), as: .psql)
    } else {
        app.databases.use(.sqlite(.memory), as: .sqlite)
    }
}

func databaseMigrations(on app: Application) throws {
    app.migrations.add(CreateTodo())
    app.migrations.add(CreateInterestGroup())
    app.migrations.add(User.Migration())
    app.migrations.add(Tag.Migration())
    app.migrations.add(UserTag.Migration())
    app.migrations.add(AddSuperUser())
    app.migrations.add(CreateVenue())
    app.migrations.add(CreateEvent())
    
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
