//
//  MonitoringResponse.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 09/03/2022.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct MonitoringResponse: Codable {    
    let status: String
    let units: MonitoringUnits
    let data: [MonitoringData]
}


struct MonitoringData: Codable {
    
    let online, offline: Double
    let timestamp: Double
    let uptime: Double
}



// MARK: - Units
struct MonitoringUnits: Codable {
    let online, offline, uptime: String
}

enum MonitoringStatus: String, Codable {
    case ok = "OK"
    case fail = "FAIL"
}
