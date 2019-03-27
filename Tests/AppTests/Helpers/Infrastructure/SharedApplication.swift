@testable import App
import Foundation
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class SharedApplication {

    private static var sharedApplication: Application? = {
        do {
            try revert()
            return try create()
        } catch {
            return nil
        }
    }()

    private init() {
    }

    class func application() throws -> Application {
        if let application = sharedApplication {
            return application
        } else {
            throw SharedApplicationError.unknown
        }
    }

    private static func create() throws -> Application {
        var config = Config.default()
        var env = Environment.testing
        var services = Services.commonWithMocks()
        try App.configure(&config, &env, &services)
        let app = try Application(config: config, environment: env, services: services)
        try App.boot(app)

        return app
    }

    private static func revert() throws {
        var config = Config.default()
        var env = Environment.testing
        env.arguments = ["vapor", "revert", "--all", "-y"]
        var services = Services.common()
        try App.configure(&config, &env, &services)

        var commandConfig = CommandConfig.default()
        commandConfig.useFluentCommands()
        services.register(commandConfig)

        let app = try Application(config: config, environment: env, services: services)
        try App.boot(app)

        try app.asyncRun().wait()
    }
}
