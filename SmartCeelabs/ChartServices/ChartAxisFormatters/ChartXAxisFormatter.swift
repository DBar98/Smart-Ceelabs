//
//  ChartXAxisFormatter.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 15/07/2021.
//

import Foundation
import Charts

class ChartXAxisFormatter: AxisValueFormatter {
    var useEpochTimestamp: Bool = false
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let epochTime =  useEpochTimestamp ? value : TimeInterval(value) / 1000
        
        let date = Date(timeIntervalSince1970: epochTime)
        return date.getFormattedDate(format: "dd.MM")
    }
}
