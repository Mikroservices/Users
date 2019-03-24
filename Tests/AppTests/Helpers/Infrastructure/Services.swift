//
//  Services.swift
//  Letterer/Services
//
//  Created by Marcin Czachurski on 22/03/2019.
//

@testable import App
import Foundation
import Vapor

extension Services {
    public static func commonWithMocks() -> Services {
        var services = Services.default()

        services.register(AuthorizationService(), as: AuthorizationServiceType.self)
        services.register(SettingsService(), as: SettingsServiceType.self)
        services.register(CaptchaService(), as: CaptchaServiceType.self)
        services.register(UsersService(), as: UsersServiceType.self)

        services.register(MockEmailsService(), as: EmailsServiceType.self)

        return services
    }
}
