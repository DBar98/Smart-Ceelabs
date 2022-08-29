//
//  YAxisValueFormatter.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 15/07/2021.
//

import Foundation
import Charts

class YAxisValueFormatter: AxisValueFormatter{
    
    var unit : String = ""
    
    init(unit: String) {
        self.unit = unit
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String{
        return String(round(10*value)/10) + "\(unit)"
    }
}
