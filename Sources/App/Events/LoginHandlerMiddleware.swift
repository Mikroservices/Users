import Vapor

struct LoginHandlerMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        
        if request.application.settings.configuration.eventsToStore.contains(.login) == false {
            return next.respond(to: request)
        }
        
        let event = Event(type: .login,
                          wasSuccess: false,
                          requestBody: self.getResponseBody(request: request))
    
        return next.respond(to: request).always { result in
            switch result {
            case .success(let response):
                do {
                    let accessTokenDto = try response.content.decode(AccessTokenDto.self)
                    event.wasSuccess = true
                    event.userId = accessTokenDto.userId
                    event.responseBody = response.body.string
                } catch {
                    request.logger.error("Error during decoding access token during logging.")
                }
            case .failure(let error):
                event.error = error.localizedDescription
            }
        }.flatMap { response in
            return event.save(on: request.db).map { _ in
                return response
            }
            
        }.flatMapError { error -> EventLoopFuture<Response> in
            return event.save(on: request.db).flatMap { _ in
                request.fail(error)
            }
        }
    }
    
    private func getResponseBody(request: Request) -> String? {
        do {
            var loginRequestDto = try request.content.decode(LoginRequestDto.self)
            loginRequestDto.password = "********"
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(loginRequestDto)
            return String(data: data, encoding: .utf8)
        } catch {
            request.logger.error("Error during decoding access token during logging.")
            return nil
        }
    }
}
