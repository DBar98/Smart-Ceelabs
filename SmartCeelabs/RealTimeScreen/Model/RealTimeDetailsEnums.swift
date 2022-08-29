//
//  RealTimeDetailsService.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 08/12/2021.
//

import Foundation

enum RealTimeDetailsEnum {
    
    case VOLTAGE(webSocketArrayToParse: [WebSocketResponse])
    case CURRENT(webSocketArrayToParse: [WebSocketResponse])
    case ACTIVEPOWER(webSocketArrayToParse: [WebSocketResponse])
    case REACTIVEPOWER(webSocketArrayToParse: [WebSocketResponse])
    case APPARENTPOWER(webSocketArrayToParse: [WebSocketResponse])
    case ENERGYIMPORT(webSocketArrayToParse: [WebSocketResponse])
    case ENERGYEXPORT(webSocketArrayToParse: [WebSocketResponse])
    
    var arrayFromWebSocketResponese: RealTimeDetailsEnumResponse{
        get{
            var phaseL1TimeAndDataArray: [[Double]] = []
            var phaseL2TimeAndDataArray: [[Double]] = []
            var phaseL3TimeAndDataArray: [[Double]] = []
            var arrayOfRealTimeChartResponses: [RealTimeDetailsChartResponse] = []
            
            switch self {
            case .VOLTAGE(let webSocketArrayToParse):
                for arrayItem in webSocketArrayToParse{
                    if let phaseL1Data = arrayItem.data.u?.l1, let ts = arrayItem.data.ts {
                        var phaseL1Array: [Double] = prepareTimeAndConsumptionRealTimeData(timestamp: phaseL1Data, data: ts)
                        phaseL1TimeAndDataArray.append(phaseL1Array)
                        phaseL1Array.removeAll()
                    }
                    if let phaseL2Data = arrayItem.data.u?.l2, let ts = arrayItem.data.ts {
                        var phaseL2Array: [Double] = prepareTimeAndConsumptionRealTimeData(timestamp: phaseL2Data, data: ts)
                        phaseL2TimeAndDataArray.append(phaseL2Array)
                        phaseL2Array.removeAll()
                    }
                    if let phaseL3Data = arrayItem.data.u?.l3, let ts = arrayItem.data.ts {
                        var phaseL3Array: [Double] = prepareTimeAndConsumptionRealTimeData(timestamp: phaseL3Data, data: ts)
                        phaseL3TimeAndDataArray.append(phaseL3Array)
                        phaseL3Array.removeAll()
                    }
                }

            case .CURRENT(let webSocketArrayToParse):
                for arrayItem in webSocketArrayToParse {
                    if let phaseL1Data = arrayItem.data.i?.l1, let ts = arrayItem.data.ts {
                        var phaseL1Array: [Double] = prepareTimeAndConsumptionRealTimeData(timestamp: phaseL1Data, data: ts)
                        phaseL1TimeAndDataArray.append(phaseL1Array)
                        phaseL1Array.removeAll()
                    }
                    if let phaseL2Data = arrayItem.data.i?.l2, let ts = arrayItem.data.ts {
                        var phaseL2Array: [Double] = prepareTimeAndConsumptionRealTimeData(timestamp: phaseL2Data, data: ts)
                        phaseL2TimeAndDataArray.append(phaseL2Array)
                        phaseL2Array.removeAll()
                    }
                    if let phaseL3Data = arrayItem.data.i?.l3, let ts = arrayItem.data.ts {
                        var phaseL3Array: [Double] = prepareTimeAndConsumptionRealTimeData(timestamp: phaseL3Data, data: ts)
                        phaseL3TimeAndDataArray.append(phaseL3Array)
                        phaseL3Array.removeAll()
                    }
                }
            case .ACTIVEPOWER(let webSocketArrayToParse):
                for arrayItem in webSocketArrayToParse{
                    if let phaseL1Data = arrayItem.data.p?.l1, let ts = arrayItem.data.ts {
                        var phaseL1Array: [Double] = prepareTimeAndConsumptionRealTimeData(timestamp: phaseL1Data, data:ts)
                        phaseL1TimeAndDataArray.append(phaseL1Array)
                        phaseL1Array.removeAll()
                    }
                    if let phaseL2Data = arrayItem.data.p?.l2, let ts = arrayItem.data.ts {
                        var phaseL2Array: [Double] = prepareTimeAndConsumptionRealTimeData(timestamp: phaseL2Data, data: ts)
                        phaseL2TimeAndDataArray.append(phaseL2Array)
                        phaseL2Array.removeAll()
                    }
                    if let phaseL3Data = arrayItem.data.p?.l3, let ts = arrayItem.data.ts {
                        var phaseL3Array: [Double] = prepareTimeAndConsumptionRealTimeData(timestamp: phaseL3Data, data: ts)
                        phaseL3TimeAndDataArray.append(phaseL3Array)
                        phaseL3Array.removeAll()
                    }
                }
            case .REACTIVEPOWER(let webSocketArrayToParse):
                for arrayItem in webSocketArrayToParse{
                    if let phaseL1Data = arrayItem.data.q?.l1, let ts = arrayItem.data.ts {
                        var phaseL1Array: [Double] = prepareTimeAndConsumptionRealTimeData(timestamp: phaseL1Data, data: ts)
                        phaseL1TimeAndDataArray.append(phaseL1Array)
                        phaseL1Array.removeAll()
                    }
                    if let phaseL2Data = arrayItem.data.q?.l2, let ts = arrayItem.data.ts {
                        var phaseL2Array: [Double] = prepareTimeAndConsumptionRealTimeData(timestamp: phaseL2Data, data: ts)
                        phaseL2TimeAndDataArray.append(phaseL2Array)
                        phaseL2Array.removeAll()
                    }
                    if let phaseL3Data = arrayItem.data.q?.l3, let ts = arrayItem.data.ts {
                        var phaseL3Array: [Double] = prepareTimeAndConsumptionRealTimeData(timestamp: phaseL3Data, data: ts)
                        phaseL3TimeAndDataArray.append(phaseL3Array)
                        phaseL3Array.removeAll()
                    }
                }
            case .APPARENTPOWER(let webSocketArrayToParse):
                for arrayItem in webSocketArrayToParse{
                    if let phaseL1Data = arrayItem.data.s?.l1, let ts = arrayItem.data.ts {
                        var phaseL1Array: [Double] = prepareTimeAndConsumptionRealTimeData(timestamp: phaseL1Data, data: ts)
                        phaseL1TimeAndDataArray.append(phaseL1Array)
                        phaseL1Array.removeAll()
                    }
                    if let phaseL2Data = arrayItem.data.s?.l2, let ts = arrayItem.data.ts {
                        var phaseL2Array: [Double] = prepareTimeAndConsumptionRealTimeData(timestamp: phaseL2Data, data: ts)
                        phaseL2TimeAndDataArray.append(phaseL2Array)
                        phaseL2Array.removeAll()
                    }
                    if let phaseL3Data = arrayItem.data.s?.l3, let ts = arrayItem.data.ts {
                        var phaseL3Array: [Double] = prepareTimeAndConsumptionRealTimeData(timestamp: phaseL3Data, data: ts)
                        phaseL3TimeAndDataArray.append(phaseL3Array)
                        phaseL3Array.removeAll()
                    }
                }
            case .ENERGYIMPORT(let webSocketArrayToParse):
                for arrayItem in webSocketArrayToParse {
                    if let phaseL1Data = arrayItem.data.eI?.l1, let ts = arrayItem.data.ts {
                        var phaseL1Array: [Double] = prepareTimeAndConsumptionRealTimeData(timestamp: phaseL1Data, data: ts)
                        phaseL1TimeAndDataArray.append(phaseL1Array)
                        phaseL1Array.removeAll()
                    }
                    if let phaseL2Data = arrayItem.data.eI?.l2, let ts = arrayItem.data.ts {
                        var phaseL2Array: [Double] = prepareTimeAndConsumptionRealTimeData(timestamp: phaseL2Data, data: ts)
                        phaseL2TimeAndDataArray.append(phaseL2Array)
                        phaseL2Array.removeAll()
                    }
                    if let phaseL3Data = arrayItem.data.eI?.l3, let ts = arrayItem.data.ts {
                        var phaseL3Array: [Double] = prepareTimeAndConsumptionRealTimeData(timestamp: phaseL3Data, data: ts)
                        phaseL3TimeAndDataArray.append(phaseL3Array)
                        phaseL3Array.removeAll()
                    }
                }
            case .ENERGYEXPORT(let webSocketArrayToParse):
                for arrayItem in webSocketArrayToParse {
                    if let phaseL1Data = arrayItem.data.eE?.l1, let ts = arrayItem.data.ts {
                        var phaseL1Array: [Double] = prepareTimeAndConsumptionRealTimeData(timestamp: phaseL1Data, data: ts)
                        phaseL1TimeAndDataArray.append(phaseL1Array)
                        phaseL1Array.removeAll()
                    }
                    if let phaseL2Data = arrayItem.data.eE?.l2, let ts = arrayItem.data.ts {
                        var phaseL2Array: [Double] = prepareTimeAndConsumptionRealTimeData(timestamp: phaseL2Data, data: ts)
                        phaseL2TimeAndDataArray.append(phaseL2Array)
                        phaseL2Array.removeAll()
                    }
                    if let phaseL3Data = arrayItem.data.eE?.l3, let ts = arrayItem.data.ts {
                        var phaseL3Array: [Double] = prepareTimeAndConsumptionRealTimeData(timestamp: phaseL3Data, data: ts)
                        phaseL3TimeAndDataArray.append(phaseL3Array)
                        phaseL3Array.removeAll()
                    }
                }
            }
            let phaseL1Struct =  RealTimeDetailsChartResponse(phaseName: "L1", timestampAndDataDoubleAray: phaseL1TimeAndDataArray)
            
            let phaseL2Struct =  RealTimeDetailsChartResponse(phaseName: "L2", timestampAndDataDoubleAray: phaseL2TimeAndDataArray)
            
            let phaseL3Struct =  RealTimeDetailsChartResponse(phaseName: "L3", timestampAndDataDoubleAray: phaseL3TimeAndDataArray)
            
            return RealTimeDetailsEnumResponse(phaseL1: phaseL1Struct, phaseL2: phaseL2Struct, phaseL3: phaseL3Struct)
        }
    }
    
    private func prepareTimeAndConsumptionRealTimeData(timestamp: Double, data: Double) -> [Double]{
        var phaseArray: [Double] = []
        
        phaseArray.append(data)
        phaseArray.append(timestamp)
        return phaseArray
    }
}

