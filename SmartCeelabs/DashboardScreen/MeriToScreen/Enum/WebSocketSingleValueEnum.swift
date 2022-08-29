//
//  WebSocketSingleValueEnum.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 23/01/2022.
//

import Foundation


enum WebSocketSingleValueEnum {
    case voltage(webSocketResponse: [WebSocketResponse])
    case current(webSocketResponse: [WebSocketResponse])
    case activePower(webSocketResponse: [WebSocketResponse])
    case reactivePower(webSocketResponse: [WebSocketResponse])
    
    
    var realTimeValue: Double{
        get{
            var phaseL1: Double = 0.0
            var phaseL2: Double = 0.0
            var phaseL3: Double = 0.0
            switch self {
            case .voltage(let webSocketResponse):
                for response in webSocketResponse {
                    phaseL1 = response.data.u?.l1 ?? 0.0
                    phaseL2 = response.data.u?.l2 ?? 0.0
                    phaseL3 = response.data.u?.l3 ?? 0.0
                }
            case .current(let webSocketResponse):
                for response in webSocketResponse {
                    phaseL1 = response.data.i?.l1 ?? 0.0
                    phaseL2 = response.data.i?.l2 ?? 0.0
                    phaseL3 = response.data.i?.l3 ?? 0.0
                    return Double(round(10 * (phaseL1 + phaseL2 + phaseL3)) / 10)
                }
            case .activePower(let webSocketResponse):
                for response in webSocketResponse {
                    phaseL1 = response.data.p?.l1 ?? 0.0
                    phaseL2 = response.data.p?.l2 ?? 0.0
                    phaseL3 = response.data.p?.l3 ?? 0.0
                    return Double(round(10 * (phaseL1 + phaseL2 + phaseL3)) / 10)
                }
            case .reactivePower(let webSocketResponse):
                for response in webSocketResponse {
                    phaseL1 = response.data.q?.l1 ?? 0.0
                    phaseL2 = response.data.q?.l2 ?? 0.0
                    phaseL3 = response.data.q?.l3 ?? 0.0
                }
            }
            return Double(round(10 * (phaseL1 + phaseL2 + phaseL3) / 3) / 10)
        }
    }
}

