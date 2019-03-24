import Vapor

extension Services {
    public static func common() -> Services {
        var services = Services.default()

        services.register(AuthorizationService(), as: AuthorizationServiceType.self)
        services.register(SettingsService(), as: SettingsServiceType.self)
        services.register(CaptchaService(), as: CaptchaServiceType.self)
        services.register(UsersService(), as: UsersServiceType.self)
        services.register(EmailsService(), as: EmailsServiceType.self)

        return services
    }
}
