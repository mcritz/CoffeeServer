import Fluent
import FluentPostgresDriver
#if DEBUG
import FluentSQLiteDriver
#endif
import Vapor
import JWT

fileprivate enum ConfigureError: Error {
    case environmentNotSet(reason: String)
}

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    try configureDatabase(on: app)
    try databaseMigrations(on: app)
    
    try configureJWT(on: app)
    
    try routes(app)
}

func configureDatabase(on app: Application) throws {
    if app.environment.name != Environment.testing.name {
        guard let username = Environment.get("DATABASE_USERNAME"),
              let database = Environment.get("DATABASE_NAME") else {
            throw ConfigureError.environmentNotSet(reason: "Database configuration not set in environment")
        }
        app.databases.use(.postgres(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
            username: username,
            password: Environment.get("DATABASE_SECRET") ?? "",
            database: database
        ), as: .psql)
    } else {
        #if DEBUG
        // Environment is testing. Use in-memory sqlite.
        app.databases.use(.sqlite(.memory), as: .sqlite)
        #else
        preconditionFailure("Incompatible enivornment: \(app.environment.name)")
        #endif
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
    
    // Always automigrate dev/test
    #if DEBUG
    print("DEBUG: Automigrate Start")
    try app.autoMigrate().wait()
    print("DEBUG: Automigrate Done")
    #endif
}

func configureJWT(on app: Application) throws {
    guard let secret = Environment.get("JWT_SIGNING_SECRET") else {
        throw ConfigureError.environmentNotSet(reason: "NO JWT_SIGNING_SECRET set in envirnoment")
    }
    app.jwt.signers.use(.hs256(key: secret))
}
