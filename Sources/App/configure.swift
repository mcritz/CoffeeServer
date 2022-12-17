import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "mcritz",
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: Environment.get("DATABASE_NAME") ?? "mcritz"
    ), as: .psql)

    app.migrations.add(CreateTodo())
    app.migrations.add(CreateInterestGroup())
    app.migrations.add(User.Migration())
    app.migrations.add(Tag.Migration())
    app.migrations.add(UserTag.Migration())
    
    #if DEBUG
    print("DEBUG: Automigrate Start")
    try app.autoMigrate().wait()
    print("DEBUG: Automigrate Done")
    #endif

    // register routes
    try routes(app)
}
