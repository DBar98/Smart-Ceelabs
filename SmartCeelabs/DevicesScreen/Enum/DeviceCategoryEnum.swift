//
//  DeviceCategoryEnum.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 19/02/2022.
//

import Foundation

enum DeviceCategoryEnum: Int {
    case disconnector = 2
    case meriTo = 1
    
    var category: [String]{
        get {
            switch self {
            case .disconnector:
                return ["Dashboard", "Timeline", "Monitoring"]
            case .meriTo:
                return ["Dashboard", "Stats", "Monitoring"]
            }
        }
    }
}
