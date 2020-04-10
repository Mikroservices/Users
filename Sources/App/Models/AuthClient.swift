import Vapor
import Fluent

public enum AuthClientType: String, Codable {
    case apple
    case google
    case microsoft
}

final class AuthClient: Model {

    static let schema = "AuthClients"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "type")
    var type: AuthClientType

    @Field(key: "name")
    var name: String

    @Field(key: "uri")
    var uri: String
    
    @Field(key: "tenantId")
    var tenantId: String?

    @Field(key: "clientId")
    var clientId: String

    @Field(key: "clientSecret")
    var clientSecret: String

    @Field(key: "callbackUrl")
    var callbackUrl: String
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deletedAt", on: .delete)
    var deletedAt: Date?
}
