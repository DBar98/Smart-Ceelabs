//
//  ChartXAxisFormatterForHoursMinutesSeconds.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 22/12/2021.
//

import Foundation
import Charts

class ChartXAxisFormatterHoursMinutesSeconds: AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let epochTime = TimeInterval(value)
        let date = Date(timeIntervalSince1970: epochTime)
        return date.getFormattedDate(format: "HH:mm:ss")
    }
}
