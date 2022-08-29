//
//  DashboardQuickRealTimeEnum.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 19/02/2022.
//

import Foundation
import UIKit

enum DashboardRealTimeMenuEnum: String, CaseIterable {

    case voltage = "Voltage"
    case current = "Current"
    case reactivePower = "Reactive Power"
    case activePower = "Active Power"
    
    var image: UIImage? {
        get {
            switch self {
            case .voltage:
                return UIImage(named: "power")?.withTintColor(.white)
            case .current:
                return UIImage(named: "flash")?.withTintColor(.white)
            case .activePower:
                return UIImage(named: "lightBulb")?.withTintColor(.white)
            case .reactivePower:
                return UIImage(named: "bars")?.withTintColor(.white)
            }
        }
    }
    
    func localize() -> String{
        return NSLocalizedString(self.rawValue, comment: "")
    }

    func getValue(forApiPurposes apiUsage: Bool) -> String{
        if !apiUsage{
            return localize()
        }else{
            return self.rawValue
        }
    }
}


