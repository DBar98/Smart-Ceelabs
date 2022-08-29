//
//  TimeUnitsEnum.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 15/11/2021.
//

import Foundation

enum TimeUnitsTypesEnum {
    case daily
    case weekly
    case monthly
    case oneDay
    
    var timeUnits: [TimeUnitsEnum]{
        get {
            switch self {
            case .daily:
                return [TimeUnitsEnum.Today, TimeUnitsEnum.Yesterday, TimeUnitsEnum.Last7Days, TimeUnitsEnum.Last14Days, TimeUnitsEnum.custom]
            case .monthly:
                return [TimeUnitsEnum.thisYear, TimeUnitsEnum.lastYear]
            case .weekly:
                return [TimeUnitsEnum.Last7Days, TimeUnitsEnum.Last14Days, TimeUnitsEnum.custom]
            case .oneDay:
                return [TimeUnitsEnum.Today, TimeUnitsEnum.Yesterday, TimeUnitsEnum.custom]
            }
        }
    }
}

enum TimeUnitsEnum: String, CaseIterable {
    
    case Today = "Today"
    case Yesterday = "Yesterday"
    case Last7Days = "Last 7 Days"
    case Last14Days = "Last 14 Days"
    case LastMonth = "Last Month"
    case lastYear = "Last Year"
    case thisYear = "This Year"
    case custom = "Custom Interval"
    
    var getTimestamp: String {
        
            get {
                switch self {
                case .Today:
                    return String (Date().startOfDay.timeIntervalSince1970).components(separatedBy: ".").first ?? ""
                case .Yesterday:
                    return String ((Calendar.current.date(byAdding: .hour, value: -(currentHours + 24), to: Date())?.startOfDay.timeIntervalSince1970)!).components(separatedBy: ".").first ?? ""
                case .Last7Days:
                    return String (Calendar.current.date(byAdding: .hour,
                                                         value: -144,
                                                         to:Date())?.startOfDay.timeIntervalSince1970 ?? 0).components(separatedBy: ".").first ?? ""
                case .Last14Days:
                    return String (Calendar.current.date(byAdding: .hour, value: -336, to: Date())?.startOfDay.timeIntervalSince1970 ?? 0).components(separatedBy: ".").first ?? ""
                case .LastMonth:
                    return String (Calendar.current.date(byAdding: .hour, value: -672, to: Date())?.startOfDay.timeIntervalSince1970 ?? 0).components(separatedBy: ".").first ?? ""
                case .custom:
                    return ""
                case .lastYear:
                    return String (firstDayOfLastYear).components(separatedBy: ".").first ?? ""
                case .thisYear:
                    return String (firstDayOfTheYear).components(separatedBy: ".").first ?? ""
                }
        }
    }
}

// Get the current year
let year = Calendar.current.component(.year, from: Date())
let firstDayOfTheYear = Calendar.current.date(from: DateComponents(year: year, month: 1, day: 1))?.timeIntervalSince1970 ?? 0
let firstDayOfLastYear = Calendar.current.date(from: DateComponents(year: year - 1, month: 1, day: 1))?.timeIntervalSince1970 ?? 0

let consumptionDetailModel = ConsumptionDetailModel()
let currentHours = consumptionDetailModel.epochTimeToDateTime(unixTime: NSDate().timeIntervalSince1970).get(.hour)
let currentMonth = consumptionDetailModel.epochTimeToDateTime(unixTime: Date().timeIntervalSince1970).get(.month)
