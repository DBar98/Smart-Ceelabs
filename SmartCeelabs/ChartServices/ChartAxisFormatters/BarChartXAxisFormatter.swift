//
//  BarChartXAxisFormatter.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 03/03/2022.
//

import Foundation
import Charts

class BarChartXAxisFormatter: AxisValueFormatter {
    var values: [Double] = []

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        var date: Date
        if !values.isEmpty{
          
            if values[0] > Calendar.current.date(byAdding: .hour, value: -48, to: Date())!.timeIntervalSince1970 {
                
                date = Date(timeIntervalSince1970: values[Int(value)])
                return date.getFormattedDate(format: "HH:mm")
            } else {
            date = Date(timeIntervalSince1970: values[Int(value)])
            return date.getFormattedDate(format: "dd.MM")
            }
        } else {
            return ""
        }
    }
}
