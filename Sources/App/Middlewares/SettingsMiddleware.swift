//
//  SettingsMiddleware.swift
//  App
//
//  Created by Marcin Czachurski on 20/03/2019.
//

import Vapor

final class SettingsMiddleware: Middleware, ServiceType {

    static func makeService(for worker: Container) throws -> SettingsMiddleware {
        return SettingsMiddleware()
    }

    public func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {

        print("Refreshing settings from database...")

        return Setting.query(on: request).all().flatMap(to: Response.self) { settings in

            let settingsService = try request.make(SettingsService.self)
            settingsService.configure(settings: settings)

            return try next.respond(to: request)
        }
    }
}