import Foundation
import Random
import Crypto

public class Password {
    public static func generateSalt() throws -> String {
        let randomData = try URandom().generateData(count: 16)
        let encodedSalt = randomData.base64EncodedString()
        return encodedSalt
    }

    public static func hash(_ password: String, withSalt salt: String) throws -> String {
        let passwordData = try SHA256.hash("\(salt)+\(password)")
        return passwordData.hexEncodedString()
    }
}
