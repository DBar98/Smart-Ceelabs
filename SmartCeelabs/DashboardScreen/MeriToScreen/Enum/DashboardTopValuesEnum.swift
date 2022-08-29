//
//  ProfileDetailPhaseInfoService.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 22/11/2021.
//

import Foundation
import UIKit


enum ProfileDetailPhaseInfoEnums{
    case MIN(arrayOfValues: [[Double]])
    case MAX(arrayOfValues: [[Double]])
    case AVG(arrayOfValues: [[Double]])
    
    var getTopValue: Double{
        get{
            switch self {
                case .MIN(let arrayOfValues):
                if arrayOfValues.count > 0{
                    let minValueFromArray = DoubleArrayUtilsEnum.SecondHalf(array: arrayOfValues).chosenArray.min() ?? 0
                    return getRoundedValueToOneDigit(valueToRound: minValueFromArray)
                }
                case .MAX(let arrayOfValues):
                if arrayOfValues.count > 0{
                    let maxValueFromArray =  DoubleArrayUtilsEnum.SecondHalf(array: arrayOfValues).chosenArray.max() ?? 0
                    return getRoundedValueToOneDigit(valueToRound: maxValueFromArray)
                }
                case .AVG(let arrayOfValues):
                if arrayOfValues.count > 0{
                    let avgValueFromArray =  getSumOfArray(arrayOfValues: DoubleArrayUtilsEnum.SecondHalf(array: arrayOfValues).chosenArray) / Double(arrayOfValues.count)
                    return getRoundedValueToOneDigit(valueToRound: avgValueFromArray)
                }
            }
            return 0.0
        }
        
    }

    
    private func getSumOfArray(arrayOfValues: [Double]) -> Double{
        var sumOfValues = 0.0
        
        arrayOfValues.forEach{ value in
            sumOfValues += value
        }
        return sumOfValues
    }
    
    private func getRoundedValueToOneDigit(valueToRound: Double) -> Double{
        return Double(round(10*valueToRound)/10)
    }
}

