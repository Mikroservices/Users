//
//  SharedApplication.swift
//  Letterer/Users
//
//  Created by Marcin Czachurski on 21/03/2019.
//

import Foundation
import App
import XCTest
import Vapor
import XCTest
import FluentPostgreSQL

final class SharedApplication {

    private static var sharedApplication: Application? = {
        do {
            var config = Config.default()
            var env = Environment.testing
            var services = Services.default()
            try App.configure(&config, &env, &services)
            let app = try Application(config: config, environment: env, services: services)
            try App.boot(app)

            return app
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
}
