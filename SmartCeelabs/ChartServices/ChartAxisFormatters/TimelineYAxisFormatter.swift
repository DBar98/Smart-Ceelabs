//
//  TimelineYAxisFormatter.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 05/03/2022.
//

import Foundation
import Charts

class TimelineYAxisFormatter: YAxisValueFormatter {
    func secondsToHours(_ seconds: Int) -> Int {
        return seconds / 3600
    }
    
    func secondsToMinutes(_ seconds: Int) -> Int {
        return (seconds / 60)
    }
    
    override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let hours = secondsToHours(Int(value))
        let minutes = self.secondsToMinutes(Int(value))
        if minutes < 1 {
            return String(format: "%.0f Sec", value)
//            return ("\(value) Sec")
        } else if hours < 1 {
            return ("\(minutes) Min")
        } else {
            return ("\(hours) Hrs")
        }
    }
}
