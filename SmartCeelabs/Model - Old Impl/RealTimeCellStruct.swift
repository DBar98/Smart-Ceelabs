//
//  RealTimeCellStruct.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 27/06/2021.
//

import UIKit

struct RealTimeCellStruct {
    var upperLabel: String
    var bottomLabel: String
    var backgroundColor: UIColor
}

let realTimeCells : [RealTimeCellStruct] = [
    RealTimeCellStruct(upperLabel: "V", bottomLabel: "VOLTAGE", backgroundColor: hexStringToUIColorRealTime(hex: "#47597E")),
    RealTimeCellStruct(upperLabel: "C", bottomLabel: "CURRENT", backgroundColor: hexStringToUIColorRealTime(hex: "#DBE6FD")),
    RealTimeCellStruct(upperLabel: "AP", bottomLabel: "ACTIVE POWER", backgroundColor: hexStringToUIColorRealTime(hex: "#47597E")),
    RealTimeCellStruct(upperLabel: "RP", bottomLabel: "REACTIVE POWER", backgroundColor: hexStringToUIColorRealTime(hex: "#DBE6FD")),
    RealTimeCellStruct(upperLabel: "AP", bottomLabel: "APPARENT POWER", backgroundColor: hexStringToUIColorRealTime(hex: "#47597E")),
    RealTimeCellStruct(upperLabel: "EI", bottomLabel: "ENERGY IMPORT", backgroundColor: hexStringToUIColorRealTime(hex: "#DBE6FD")),
    RealTimeCellStruct(upperLabel: "EE", bottomLabel: "ENERGY EXPORT", backgroundColor: hexStringToUIColorRealTime(hex: "#47597E")),
]

func hexStringToUIColorRealTime (hex:String) -> UIColor {
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
