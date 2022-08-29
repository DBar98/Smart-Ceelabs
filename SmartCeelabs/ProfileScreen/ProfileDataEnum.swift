//
//  ProfileDataEnum.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 21/02/2022.
//

import Foundation

enum ProfileDataEnum: String {
    
    case voltage = "Voltage"
    case current = "Current"
    case activePower = "Active Power"
    case reactivePower = "Reactive Power"
    case apparentPower = "Apparent Power"
    case energyImport = "Energy Import"
    case energyExport = "Energy Export"
    
    var getDataShortuct: String {
        switch self {
        case .voltage:
            return "U"
        case .current:
            return "I"
        case .apparentPower:
            return "S"
        case .reactivePower:
            return "Q"
        case .activePower:
            return "P"
        case .energyImport:
            return "E_I"
        case .energyExport:
            return "E_E"
        }
    }
    
    var getBaseUnits: String {
        switch self {
        case .voltage:
            return "V"
        case .current:
            return "A"
        case .activePower:
            return "W"
        case .reactivePower:
            return "VAr"
        case .apparentPower:
            return "VA"
        case .energyImport:
            return "kWh"
        case .energyExport:
            return "kWh"
        }
    }
}
