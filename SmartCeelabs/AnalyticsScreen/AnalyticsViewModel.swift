//
//  AnalyticsViewModel.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 27/02/2022.
//

import Foundation
import UIKit
import Charts


protocol AnalyticsViewModelInputs {
    func fetchEnergyData(energyDataType: String, timeline: AnalyticsTimelineEnum, timeFrom: String, timeTo: String, barChart: BarChartView, selectedDataType: EnergyDataOutputsEnum, currentController: UIViewController)
    func prepareChart(barChart: BarChartView)
}

protocol AnalyticsViewModelOutputs {
    var barChart: BarChartView? { get set }
    var totalValue: (([(energyType: String, energyValue: String)]) -> Void)? { get set }
    var timestampsUnitsFetched: (([Double], String) -> ())? { get set }
}

protocol AnalyticsViewModelType {
    var inputs: AnalyticsViewModelInputs { get set }
    var outputs: AnalyticsViewModelOutputs { get set }
}
class AnalyticsViewModel: AnalyticsViewModelType, AnalyticsViewModelInputs, AnalyticsViewModelOutputs {
    
    var totalValue: (([(energyType: String, energyValue: String)]) -> Void)?
    var timestampsUnitsFetched: (([Double], String) -> ())? 
    var barChart: BarChartView?
    
        
    var inputs: AnalyticsViewModelInputs { get { self } set {} }
    var outputs: AnalyticsViewModelOutputs{ get { self } set {} }
    
    var device: Device
    var networking: Networking
    var chartModel: ChartsModel
    var chartData: [ChartDatasetStruct] = []
    let url = UrlEnum.energyDataUrl.rawValue
    
    init(device: Device, networking: Networking, chartsModel: ChartsModel) {
        self.device = device
        self.networking = networking
        self.chartModel = chartsModel
    }
    
    func fetchEnergyData(energyDataType: String, timeline: AnalyticsTimelineEnum, timeFrom: String, timeTo: String, barChart: BarChartView, selectedDataType: EnergyDataOutputsEnum, currentController: UIViewController) {
    
        let request = EnergyDataRequest(token: device.token,
                                        data: "E_E, E_I,Q1,Q2,Q3,Q4",
                                        format: "H",
                                        period: timeline.timePeriod.rawValue,
                                        from: timeFrom,
                                        to: timeTo)
                
        networking.post(url: url, jsonBody: request, onCompletion: { [weak self] (response: EnergyDataResponse) in
            guard let self = self else { return }
            switch response.status {
            case .ok:
                var dataSet: [ChartDatasetStruct] = []

                let responseData = response.data.getDataByOutput(output: energyDataType)
                let unit = response.units.getDataByOutput(output: energyDataType) ?? "wh"
                
                let energyExportFiltered = ChartDatasetStruct(energyData: nil, consumptionData: responseData?.cum, labelName: selectedDataType, unit: response.units.getDataByOutput(output: energyDataType) ?? "wh")
                
                if let timestamps = responseData?.cum {
                    self.timestampsUnitsFetched?( timestamps.map {
                        $0[0]
                    }, unit)
                }

                dataSet = [energyExportFiltered]
                
                self.updateBarChart(timestampData: dataSet, barChart: barChart, units: energyExportFiltered.unit)
                
                var totalValueArray:[(String, String)] = []
                
                switch timeline {
                case .hourlyActiveReport, .dailyActiveReport, .monthlyActiveReport:
                    for item in EnergyDataOutputsEnum.ActiveEnergy.allCases {
                        let total = DoubleArrayUtilsEnum.SecondHalf(array: response.data.getDataByOutput(output: item.shortcut)?.cum ?? []).totalValue
                        var touple: (name: String, value: String) = ("", "")
                        touple.name = item.rawValue
                        touple.value = String(total.rounded(toPlaces: 1))
                        touple.value.append(contentsOf: unit)

                        totalValueArray.append(touple)
                    }
                case .dailyReactiveReport:
                    for item in EnergyDataOutputsEnum.ReactiveEnergy.allCases {
                        let total = DoubleArrayUtilsEnum.SecondHalf(array: response.data.getDataByOutput(output: item.shortcut)?.cum ?? []).totalValue
                        
                        var touple: (name: String, value: String) = ("", "")
                        touple.name = item.rawValue
                        touple.value = String(total.rounded(toPlaces: 1))
                        touple.value.append(contentsOf: unit)

                        totalValueArray.append(touple)
                    }
                }
                self.totalValue?(totalValueArray)
                //remove spinner one the data are successfully fetched
                currentController.removeSpinner()
            case .fail:
                print("🚫 Fetch data proccess failed. 🚫")
            }
        }, onError: { error in
            print("🚫 Error occured: \(error) 🚫")
        })
    }
    
    func prepareChart(barChart: BarChartView) {
        self.barChart = chartModel.prepareBarChart(barChart: barChart)
    }
    
    private func updateBarChart(timestampData: [ChartDatasetStruct], barChart: BarChartView, units: String){
        DispatchQueue.main.async {
            self.chartModel.updateBarChartData(fetchedData: timestampData, chart: barChart, units: units, stacked: false)
        }
    }
}
