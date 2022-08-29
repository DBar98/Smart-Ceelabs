//
//  StatsCollectionElementEnum.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 20/02/2022.
//

import Foundation

enum StatsColectionElementEnum: String, CaseIterable {
    case profile = "Profile"
    case realTime = "Real Time"
    case analytics = "Analytics"
    
    var elementCategories: [String] {
        get{
            switch self {
            case .profile:
                return ["Voltage", "Current", "Apparent Power", "Reactive Power", "Active Power", "Energy Import", "Energy Export"]
            case .realTime:
                return ["Voltage", "Current", "Apparent Power", "Reactive Power", "Active Power", "Energy Import", "Energy Export"]
            case .analytics:
                return ["Hourly Active Report", "Daily Active Report", "Monthly Active Report", "Daily Reactive Report"]
            }
        }
    }
}
