//
//  ConsumptionDetailModel.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 22/06/2021.
//

import Foundation

struct ConsumptionDetailModel{
        
    func epochTimeToDateTime(unixTime: Double) -> Date {
        return Date(timeIntervalSince1970: unixTime)
    }
    
    func getTimeInterval(timeInterval: String) -> String{
        var dateTimeInterval : String = ""
        
        switch timeInterval {
        case "Today":
            dateTimeInterval = String (Calendar.current.date(byAdding: .hour, value: -24, to: Date())!.timeIntervalSince1970)
            return dateTimeInterval
        case "Yesterday":
            dateTimeInterval = String (Calendar.current.date(byAdding: .hour, value: -48, to: Date())!.timeIntervalSince1970)
            return dateTimeInterval
        case "Last 7 Days":
            dateTimeInterval = String (Calendar.current.date(byAdding: .hour, value: -168, to: Date())!.timeIntervalSince1970)
            return dateTimeInterval
        case "Last 14 Days":
            dateTimeInterval = String (Calendar.current.date(byAdding: .hour, value: -336, to: Date())!.timeIntervalSince1970)
            return dateTimeInterval
        default:
            return dateTimeInterval
        }
    }
}

