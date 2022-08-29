//
//  DeviceCategoriesEnum.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 18/01/2022.
//

import Foundation
import Alamofire
import UIKit

enum EnergyDataTypeEnum: String{
    case active = "E_I, E_E"
    case reactive = "Q1, Q2, Q3, Q4"
}
enum ReactiveEnergyOutputsEnum: String, CaseIterable {
    case Q1 = "Quadrant 1"
    case Q2 = "Quadrant 2"
    case Q3 = "Quadrant 3"
    case Q4 = "Quadrant 4"
    
}

enum ActiveEnergyOutputs: String, CaseIterable {
    case energyImport = "Energy Import"
    case energyExport = "Eenrgy Export"
}

enum EnergyDataOutputsEnum: String, CaseIterable{
    case energyImport = "Energy Import"
    case energyExport = "Energy Export"
    case Q1 = "Quadrant 1"
    case Q2 = "Quadrant 2"
    case Q3 = "Quadrant 3"
    case Q4 = "Quadrant 4"
    
    enum ActiveEnergy: String, CaseIterable {
        case energyImport = "Energy Import"
        case energyExport = "Energy Export"
        
        var shortcut: String {
            switch self {
            case .energyImport:
                return "E_I"
            case .energyExport:
                return "E_E"
            }
        }
    }
    
    enum ReactiveEnergy: String, CaseIterable {
        case Q1 = "Quadrant 1"
        case Q2 = "Quadrant 2"
        case Q3 = "Quadrant 3"
        case Q4 = "Quadrant 4"
        
        var shortcut: String {
            switch self {
            case .Q1:
                return "Q1"
            case .Q2:
                return "Q2"
            case .Q3:
                return "Q3"
            case .Q4:
                return "Q4"
            }
        }
    }
    
    var energyShortcut: String {
        get {
            switch self {
            case .energyImport:
                return ActiveEnergy.energyImport.shortcut
//                return "E_I"
            case .energyExport:
                return ActiveEnergy.energyExport.shortcut
//                return "E_E"
            case .Q1:
                return ReactiveEnergy.Q1.shortcut
//                return "Q1"
            case .Q2:
                return ReactiveEnergy.Q2.shortcut
//                return "Q2"
            case .Q3:
                return ReactiveEnergy.Q3.shortcut
//                return "Q3"
            case .Q4:
                return ReactiveEnergy.Q4.shortcut
//                return "Q4"
            }
        }
    }
}

