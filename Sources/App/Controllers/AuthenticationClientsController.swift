import Vapor

final class AuthenticationClientsController: RouteCollection {

    public static let uri: PathComponent = .constant("auth-clients")
    
    func boot(routes: RoutesBuilder) throws {
        let authClientsGroup = routes
            .grouped(AuthenticationClientsController.uri)
        
        authClientsGroup
            .grouped(UserAuthenticator())
            .grouped(UserPayload.guardMiddleware())
            .grouped(UserPayload.guardIsSuperUserMiddleware())
            .grouped(EventHandlerMiddleware(.authClientsCreate))
            .post(use: create)

        authClientsGroup
            .grouped(EventHandlerMiddleware(.authClientsList))
            .get(use: list)

        authClientsGroup
            .grouped(EventHandlerMiddleware(.authClientsRead))
            .get(":id", use: read)
        
        authClientsGroup
            .grouped(UserAuthenticator())
            .grouped(UserPayload.guardMiddleware())
            .grouped(UserPayload.guardIsSuperUserMiddleware())
            .grouped(EventHandlerMiddleware(.authClientsUpdate))
            .put(":id", use: update)
        
        authClientsGroup
            .grouped(UserAuthenticator())
            .grouped(UserPayload.guardMiddleware())
            .grouped(UserPayload.guardIsSuperUserMiddleware())
            .grouped(EventHandlerMiddleware(.authClientsDelete))
            .delete(":id", use: delete)
    }

    /// Create new authentication client.
    func create(request: Request) throws -> EventLoopFuture<Response> {
        let authClientsService = request.application.services.authenticationClientsService
        let authClientDto = try request.content.decode(AuthClientDto.self)
        try AuthClientDto.validate(request)

        let validateUriFuture = authClientsService.validateUri(on: request, uri: authClientDto.uri, authClientId: nil)
        let createAuthClientFuture = validateUriFuture.map { _ in
            self.createAuthClient(on: request, authClientDto: authClientDto)
        }.flatMap { roleFuture in
            return roleFuture
        }
        
        return createAuthClientFuture.flatMapThrowing { authClient -> EventLoopFuture<Response> in
            try self.createNewAuthClientResponse(on: request, authClient: authClient)
        }.flatMap { authClientFuture in
            return authClientFuture
        }
    }

    /// Get all authentication clients.
    func list(request: Request) throws -> EventLoopFuture<[AuthClientDto]> {
        return AuthClient.query(on: request.db).all().map { authClients in
            authClients.map { authClient in AuthClientDto(from: authClient) }
        }
    }

    /// Get specific authentication client.
    func read(request: Request) throws -> EventLoopFuture<AuthClientDto> {
        
        guard let authClientId = request.parameters.get("id", as: UUID.self) else {
            throw AuthClientError.incorrectAuthClientId
        }

        return self.getAuthClientById(on: request, authClientId: authClientId).map { authClient in
            AuthClientDto(from: authClient)
        }
    }

    /// Update specific authentication client.
    func update(request: Request) throws -> EventLoopFuture<AuthClientDto> {

        guard let authClientId = request.parameters.get("id", as: UUID.self) else {
            throw AuthClientError.incorrectAuthClientId
        }
        
        let authClientsService = request.application.services.authenticationClientsService
        let authClientDto = try request.content.decode(AuthClientDto.self)
        try AuthClientDto.validate(request)
        
        let authClientFuture = self.getAuthClientById(on: request, authClientId: authClientId)
        let validateUriFuture = authClientFuture.flatMap { authClient in
            authClientsService.validateUri(on: request, uri: authClientDto.uri, authClientId: authClient.id).transform(to: authClient)
        }

        let updateFuture = validateUriFuture.flatMap { authClient in
            self.updateAuthClient(on: request, from: authClientDto, to: authClient).transform(to: authClient)
        }

        return updateFuture.map { authClient in
            AuthClientDto(from: authClient)
        }
    }

    /// Delete specific authentication client.
    func delete(request: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let authClientId = request.parameters.get("id", as: UUID.self) else {
            throw AuthClientError.incorrectAuthClientId
        }

        let authClientFuture = self.getAuthClientById(on: request, authClientId: authClientId)
        let deleteFuture = authClientFuture.flatMap { authClient in
            authClient.delete(on: request.db)
        }

        return deleteFuture.transform(to: HTTPStatus.ok)
    }

    private func createAuthClient(on request: Request, authClientDto: AuthClientDto) -> EventLoopFuture<AuthClient> {
        let authClient = AuthClient(from: authClientDto)
        return authClient.save(on: request.db).transform(to: authClient)
    }

    private func createNewAuthClientResponse(on request: Request, authClient: AuthClient) throws -> EventLoopFuture<Response> {
        let createdAuthClientDto = AuthClientDto(from: authClient)
                
        return createdAuthClientDto.encodeResponse(for: request).map { response in
            response.headers.replaceOrAdd(name: .location, value: "/\(AuthenticationClientsController.uri)/\(authClient.id?.uuidString ?? "")")
            response.status = .created

            return response
        }
    }

    private func getAuthClientById(on request: Request, authClientId: UUID) -> EventLoopFuture<AuthClient> {
        return AuthClient.find(authClientId, on: request.db).unwrap(or: EntityNotFoundError.authClientNotFound)
    }

    private func updateAuthClient(on request: Request, from authClientDto: AuthClientDto, to authClient: AuthClient) -> EventLoopFuture<Void> {
        authClient.type = authClientDto.type
        authClient.name = authClientDto.name
        authClient.uri = authClientDto.uri
        authClient.tenantId = authClientDto.tenantId
        authClient.clientId = authClientDto.clientId
        authClient.clientSecret = authClientDto.clientSecret
        authClient.callbackUrl = authClientDto.callbackUrl
        authClient.svgIcon = authClientDto.svgIcon

        return authClient.update(on: request.db)
    }
}
