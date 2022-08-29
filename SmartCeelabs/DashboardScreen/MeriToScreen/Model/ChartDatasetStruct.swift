//
//  ChartDatasetStruct.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 31/01/2022.
//

import Foundation

struct ChartDatasetStruct {
    
    var energyData: [(Double, Double)]?
    var consumptionData: [[Double]]?
    var labelName: EnergyDataOutputsEnum?
    var unit: String
}
