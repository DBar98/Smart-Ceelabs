//
//  AnalyticsCellStruct.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 03/06/2021.
//

import Foundation
import UIKit

struct AnalyticsCellStruct {
    var upperLabel: String
    var bottomLabel: String
    var backgroundColor: UIColor
}

let analyticsCells : [AnalyticsCellStruct] = [
    AnalyticsCellStruct(upperLabel: "V", bottomLabel: "VOLTAGE", backgroundColor: hexStringToUIColor(hex: "#5E8B7E")),
    AnalyticsCellStruct(upperLabel: "C", bottomLabel: "CURRENT", backgroundColor: hexStringToUIColor(hex: "#A7C4BC")),
    AnalyticsCellStruct(upperLabel: "AP", bottomLabel: "ACTIVE POWER", backgroundColor: hexStringToUIColor(hex: "#5E8B7E")),
    AnalyticsCellStruct(upperLabel: "RP", bottomLabel: "REACTIVE POWER", backgroundColor: hexStringToUIColor(hex: "#A7C4BC")),
    AnalyticsCellStruct(upperLabel: "AP", bottomLabel: "APPARENT POWER", backgroundColor: hexStringToUIColor(hex: "#5E8B7E")),
    AnalyticsCellStruct(upperLabel: "EI", bottomLabel: "ENERGY IMPORT", backgroundColor: hexStringToUIColor(hex: "#A7C4BC")),
    AnalyticsCellStruct(upperLabel: "EE", bottomLabel: "ENERGY EXPORT", backgroundColor: hexStringToUIColor(hex: "#5E8B7E")),
]

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
