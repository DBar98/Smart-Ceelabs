//
//  AnalyticsDetailViewModel.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 24/01/2022.
//

import Foundation
import Charts

class AnalyticsDetailViewModel {
    
    var networking: Networking
    var barChart: BarChartView
    
    init(){
        self.networking = Networking()
        self.barChart = BarChartView()
    }
    
    func getEnergyDataForChart(timeLineStructs: [(Double, Double)], deviceToken: String) {
        var responseDoubleData: [[Double]] = []
        
        for item in timeLineStructs {
            let request = ProfileDataRequest(token: deviceToken,
                                                     data: "P",
                                                     format: "H",
                                                     phase: "L1",
                                                     from: String(item.0).components(separatedBy: ".").first ?? "",
                                                     to: String(item.1).components(separatedBy: ".").first ?? "",
                                                     cumulative: "true")
            
            networking.post(url: "https://devel.ceelabs.com/api2-r/profile", jsonBody: request, onCompletion: { (response: Response) in
                
                var consumptionSum: Double = 0.0
                var dataByTimeValue: [(Double, Double)] = []
                
                switch response.status {
                case .ok:
                    responseDoubleData = response.data.p?.cumulative ?? []
                    //adding the consumption values to get final value per day
                    for (_, value) in responseDoubleData.enumerated() {
                        
                        consumptionSum = consumptionSum + value[1]
                    }
                    
                    dataByTimeValue.append((consumptionSum.rounded(toPlaces: 1), item.1))
                case .fail:
                    print("Data fetching error")
                }
            }, onError: { error in
                print("\(error)")
            })
        }
    }
}
