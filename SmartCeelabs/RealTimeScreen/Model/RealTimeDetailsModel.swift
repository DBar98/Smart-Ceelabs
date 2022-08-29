//
//  RealTimeDetailsModel.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 11/12/2021.
//

import Foundation

class RealTimeDetailsModel{
    
    public static func getEnumTypeByGivenString(type: String, webSocketArrayToParse: [WebSocketResponse]) throws -> RealTimeDetailsEnum {
        switch type{
        case "VOLTAGE":
            return .VOLTAGE(webSocketArrayToParse: webSocketArrayToParse)
        case "CURRENT":
            return .CURRENT(webSocketArrayToParse: webSocketArrayToParse)
        case "ACTIVE POWER":
            return .ACTIVEPOWER(webSocketArrayToParse: webSocketArrayToParse)
        case "REACTIVE POWER":
            return .REACTIVEPOWER(webSocketArrayToParse: webSocketArrayToParse)
        case "APPAREN POWER":
            return .APPARENTPOWER(webSocketArrayToParse: webSocketArrayToParse)
        case "ENERGY IMPORT":
            return .ENERGYIMPORT(webSocketArrayToParse: webSocketArrayToParse)
        case "ENERGY EXPORT":
            return .ENERGYEXPORT(webSocketArrayToParse: webSocketArrayToParse)
        default:
            throw RealTimeDetailsCustomExceptions.wrongEnumValue
        }
    }
}
