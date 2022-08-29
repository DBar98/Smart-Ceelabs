import Foundation

struct ApparentPowerResponse: Codable {
    let status: ApparentPowerResponseStatus
    let units: ApparentPowerUnits?
    let data: ApparentPowerData?
    let code: Int?
    let message: String?
}

struct ApparentPowerData: Codable {
    let q1, q2, q3, q4: Q

    enum CodingKeys: String, CodingKey {
        case q1 = "Q1"
        case q2 = "Q2"
        case q3 = "Q3"
        case q4 = "Q4"
    }
}

struct Q: Codable {
    let cumulative, l1, l2, l3: [[Double]]

    enum CodingKeys: String, CodingKey {
        case cumulative
        case l1 = "L1"
        case l2 = "L2"
        case l3 = "L3"
    }
}

enum ApparentPowerResponseStatus: String, Codable {
    case ok = "OK"
    case fail = "FAIL"
}

struct ApparentPowerUnits: Codable {
}
