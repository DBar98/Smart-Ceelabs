//
//  AnalyticsTimeLineEnum.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 24/01/2022.
//

import Foundation

enum StaticTimeIntervalEnum: String, CaseIterable {
    case today = "Today"
    case lastWeek = "Last week"
    case lastMonth = "Last month"
    case lastYear = "Last Year"
    
    var getTimeInterval: String {
        get{
            let date: Date?
            switch self {
            case .today:
                date = Calendar.current.date(byAdding: .hour, value: -(currentHours + 1), to: Date())
            case .lastWeek:
                date = Calendar.current.date(byAdding: .hour, value: -(currentHours + (6*24)), to: Date())
            case .lastMonth:
                date = Calendar.current.date(byAdding: .hour, value: -(currentHours + (30*24)), to: Date())
            case .lastYear:
                date = Calendar.current.date(byAdding: .hour, value: -(currentHours + (365*24)), to: Date())
            }
            
            if let date = date {
                return String(date.timeIntervalSince1970)
            } else {
                return ""
            }
        }
    }
}

enum EnergyDataTimeIntervalsEnum: String, CaseIterable {
    case last24Hours = "Last 24 hours"
    case last14Days = "Last 14 days"
    case last12Months = "Last 12 months"
    
    var getTimePeriod: PeriodType {
        get {
            switch self {
            case .last24Hours:
                return .hour
            case .last14Days:
                return .day
            case .last12Months:
                return .month
            }
        }
    }
    
    var getTimeInterval: String {
        get {
            let date: Date?
            switch self {
            case.last24Hours :
                date = Calendar.current.date(byAdding: .hour, value: -24, to: Date())
            case .last14Days:
                date = Calendar.current.date(byAdding: .hour, value: -(24*14), to: Date())
            case .last12Months:
                date = Calendar.current.date(byAdding: .hour, value: -(24*365), to: Date())
            }
            if let date = date {
                return String(date.timeIntervalSince1970)
            } else {
                return ""
            }
        }
    }

}
