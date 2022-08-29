//
//  AnalyticsScreenCellEnum.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 23/01/2022.
//

import Foundation
import UIKit

enum AnalyticsScreenCellEnum : String, CaseIterable{
    
        
    case mi15m = "Maximum in 15 minutes"
    case qhar = "Quater hour active report"
    case har = "Hourly active report"
    case dar = "Daily active report"
    case mar = "Monthly active report"
    case drr = "Daily reactive report"
    
    var getShortcut: String {
        switch self {
        case .mi15m:
            return "MI15M"
        case .qhar:
            return "QHAR"
        case .har:
            return "HAR"
        case .dar:
            return "DAR"
        case .mar:
            return "MAR"
        case .drr:
            return "DDR"
        }
    }
    
    var getBackgroundColor: UIColor {
        switch self {
        case .mi15m:
            return UIColor(red: 251, green: 140, blue: 0)
        case .qhar:
            return UIColor(red: 255, green: 167, blue: 38)
        case .har:
            return UIColor(red: 251, green: 140, blue: 0)
        case .dar:
            return UIColor(red: 255, green: 167, blue: 38)
        case .mar:
            return UIColor(red: 251, green: 140, blue: 0)
        case .drr:
            return UIColor(red: 255, green: 167, blue: 38)
        }
    }
    
    var getTimelineItems: [String] {
        switch self {
        case .mi15m:
            return ["Today", "Yesterday", "Last 7 days", "Last 14 days"]
        case .qhar:
            return ["Today", "Yesterday", "Last 7 days", "Last 14 days"]
        case .har:
            return ["Today", "Yesterday", "Last 7 days", "Last 14 days"]
        case .dar:
            return ["Last 7 days", "Last 14 days"]
        case .mar:
            return ["This year", "Last year"]
        case .drr:
            return ["Today", "Yesterday", "Last 7 days", "Last 14 days"]
        }
    }
}
