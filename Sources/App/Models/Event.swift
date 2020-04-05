import Fluent
import Vapor

public enum EventType: String, Codable {
    case login
    case changePassword
}

final class Event: Model {

    static let schema = "Events"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "type")
    var type: EventType
    
    @Field(key: "wasSuccess")
    var wasSuccess: Bool
    
    @Field(key: "userId")
    var userId: UUID?
    
    @Field(key: "requestBody")
    var requestBody: String?
    
    @Field(key: "responseBody")
    var responseBody: String?

    @Field(key: "error")
    var error: String?
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?

    init() { }
    
    init(id: UUID? = nil, type: EventType, wasSuccess: Bool, userId: UUID? = nil,
         requestBody: String? = nil, responseBody: String? = nil, error: String? = nil) {
        self.id = id
        self.type = type
        self.wasSuccess = wasSuccess
        self.userId = userId
        self.requestBody = requestBody
        self.responseBody = responseBody
        self.error = error
    }
}

/// Allows `Log` to be encoded to and decoded from HTTP messages.
extension Event: Content { }
