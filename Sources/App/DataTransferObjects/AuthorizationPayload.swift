import Foundation
import JWT

struct AuthorizationPayload: JWTPayload {
    var id: UUID?
    var userName: String
    var name: String?
    var email: String
    var exp: Date
    var gravatarHash: String

    func verify(using signer: JWTSigner) throws {
        // nothing to verify
    }
}
