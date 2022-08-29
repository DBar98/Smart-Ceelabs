//
//  DoubleExtension.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 24/01/2022.
//

import Foundation

extension Double {
    func rounded(toPlaces places:Int) -> Double {
           let divisor = pow(10.0, Double(places))
           return (self * divisor).rounded() / divisor
       }
}
