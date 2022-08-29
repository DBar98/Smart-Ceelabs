
import Foundation

// MARK: - Welcome
struct RelayResponse: Codable {
    let status: RelayResopnseStatus
    let data: RelayData?
    let message: String?
}

// MARK: - DataClass
struct RelayData: Codable {
    let r1, r2, r3, r4: Outlets

    enum CodingKeys: String, CodingKey {
        case r1 = "R1"
        case r2 = "R2"
        case r3 = "R3"
        case r4 = "R4"
    }
}

// MARK: - R1
struct Outlets: Codable {
    let power: Double
    let name: String
}

enum RelayResopnseStatus: String, Codable {
    case ok = "OK"
    case fail = "FAIL"
}
