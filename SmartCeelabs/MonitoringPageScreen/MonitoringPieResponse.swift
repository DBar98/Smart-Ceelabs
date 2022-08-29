//
//  MonitoringPieResponse.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 10/03/2022.
//

import Foundation

// MARK: - Welcome
struct MonitoringPieResponse: Codable {
    let status: PieStatus
    let units: PieUnits
    let data: [PieData]
}

// MARK: - Datum
struct PieData: Codable {
    let timestamp, online, offline: Int
    let uptime: Double
}

// MARK: - Units
struct PieUnits: Codable {
    let online, offline, uptime: String
}

enum PieStatus: String, Codable {
case ok = "OK"
case fail = "FAIL"
}

