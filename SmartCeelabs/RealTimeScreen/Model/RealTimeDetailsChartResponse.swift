//
//  RealTimeDetailsChartResponse.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 09/12/2021.
//

import Foundation

struct RealTimeDetailsEnumResponse{
    
    internal init(phaseL1: RealTimeDetailsChartResponse, phaseL2: RealTimeDetailsChartResponse, phaseL3: RealTimeDetailsChartResponse) {
        self.phaseL1 = phaseL1
        self.phaseL2 = phaseL2
        self.phaseL3 = phaseL3
    }
    
    let phaseL1, phaseL2, phaseL3: RealTimeDetailsChartResponse
    
    public func getRealTimeDataByPhaseName(phaseName: String) throws -> RealTimeDetailsChartResponse{
        switch phaseName{
        case "L1":
            return self.phaseL1
        case "L2":
            return self.phaseL2
        case "L3":
            return self.phaseL3
        default:
            throw RealTimeDetailsCustomExceptions.wrongEnumValue
        }
    }
    
}

struct RealTimeDetailsChartResponse{
    var phaseName: String
    var timestampAndDataDoubleAray: [[Double]]
    
    internal init(phaseName: String, timestampAndDataDoubleAray: [[Double]]) {
        self.phaseName = phaseName
        self.timestampAndDataDoubleAray = timestampAndDataDoubleAray
    }
}
