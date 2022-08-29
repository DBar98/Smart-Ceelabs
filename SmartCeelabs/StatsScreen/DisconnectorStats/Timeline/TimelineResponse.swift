// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct TimelineResponse: Codable {
    let status: TimelineStatus
    let data: TimelineData
}

// MARK: - DataClass
struct TimelineData: Codable {
    let relay1, relay2, relay3, relay4: [Relay]

    enum CodingKeys: String, CodingKey {
        case relay1 = "RELAY_1"
        case relay2 = "RELAY_2"
        case relay3 = "RELAY_3"
        case relay4 = "RELAY_4"
    }
    
    func getDataByRelayIndex(idx: Int) -> [Relay]? {
        switch idx {
        case 0:
            return relay1
        case 1:
            return relay2
        case 2:
            return relay3
        case 3:
            return relay4
        default:
            return nil
        }
    }
}

// MARK: - Relay
struct Relay: Codable {
    let state: Int
    let stateHuman: StateHuman
    let start, end: Double

    enum CodingKeys: String, CodingKey {
        case state
        case stateHuman = "state_human"
        case start, end
    }
}

enum StateHuman: String, Codable {
    case off = "OFF"
    case on = "ON"
}

enum TimelineStatus: String, Codable {
    case ok = "OK"
    case fail = "FAIL"
}
