//
//  DoubleArrayUtils.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 24/11/2021.
//


/*CREATE EXTENSION FROM THIS SAMPLE*/

import Foundation

enum DoubleArrayUtilsEnum{
    /* Insert double array: [[1,1], [2,2] and choose which values should be used - first or second]*/
    case FirstHalf(array: [[Double]])
    case SecondHalf(array: [[Double]])
    
    var chosenArray: [Double]{
        get{
            var profilePhaseValues: [Double] = []

            switch self{
            case .FirstHalf(array: let array):
                for (_, array) in array.enumerated(){
                    profilePhaseValues.append(array[0])
                }
                return profilePhaseValues
            case .SecondHalf(array: let array):
                for (_, array) in array.enumerated(){
                    profilePhaseValues.append(array[1])
                }
                return profilePhaseValues
            }
        }
    }
    
    var totalValue: Double {
        get {
            var sum: Double = 0
            switch self {
            case .FirstHalf(let array):
                sum = array.map { $0[0]}.reduce(0, +)
            case .SecondHalf(let array):
                sum = array.map { $0[1]}.reduce(0, +)
            }
            return sum
        }
    }
}
