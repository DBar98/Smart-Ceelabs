import Foundation

// MARK: - Welcome
struct RefreshTokenResponse: Codable {
    let accessToken: String
    let expiresIn: Int
    let scope: String
    let tokenType, idToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case scope
        case tokenType = "token_type"
        case idToken = "id_token"
    }
}
