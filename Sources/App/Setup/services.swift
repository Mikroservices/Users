import Vapor

extension Services {
    public static func append(_ services: inout Services) {
        services.register(AuthorizationService(), as: AuthorizationServiceType.self)
        services.register(SettingsService(), as: SettingsServiceType.self)
        services.register(CaptchaService(), as: CaptchaServiceType.self)
        services.register(UsersService(), as: UsersServiceType.self)
        services.register(EmailsService(), as: EmailsServiceType.self)
    }
}
