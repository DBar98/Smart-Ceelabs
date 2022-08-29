// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct WebSocketResponse: Codable {
    let topic, device: String
    let data: WebSocketData
}

// MARK: - DataClass
struct WebSocketData: Codable {
    let ts: Double?
    let u, i, p, s: phases?
    let q, eI, eE, q1: phases?
    let q2, q3, q4: phases?
    let r1, r2, r3, r4: Bool?

    enum CodingKeys: String, CodingKey {
        case ts
        case u = "U"
        case i = "I"
        case p = "P"
        case s = "S"
        case q = "Q"
        case eI = "E_I"
        case eE = "E_E"
        case q1 = "Q1"
        case q2 = "Q2"
        case q3 = "Q3"
        case q4 = "Q4"
        case r1 = "relay_1"
        case r2 = "relay_2"
        case r3 = "relay_3"
        case r4 = "relay_4"
    }
}

// MARK: - EE
struct phases: Codable {
    let l1, l2, l3: Double?

    enum CodingKeys: String, CodingKey {
        case l1 = "L1"
        case l2 = "L2"
        case l3 = "L3"
    }
}


var webSocketResponsesArray: [WebSocketResponse] = []

