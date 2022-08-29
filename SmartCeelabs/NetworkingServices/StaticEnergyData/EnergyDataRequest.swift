//
//  EnergyDataRequest.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 18/02/2022.
//

import Foundation

struct EnergyDataRequest: Codable {
    
    var token: String
    var data: String
    var format: String
    var period: String
    let phase = "CUM"
    var from: String
    var to: String
}

enum PeriodType: String, Codable {
    case month = "MONTH"
    case day = "DAY"
    case hour = "HOUR"
}
