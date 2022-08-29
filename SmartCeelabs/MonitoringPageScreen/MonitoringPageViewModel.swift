//
//  MonitoringPageViewModel.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 09/03/2022.
//

import Foundation
import Charts

protocol MonitoringPageViewModelInputs {
    func prepareLineChart(chart: LineChartView)
    func prepareBarChart(chart: BarChartView)
    func preparePieChart(chart: PieChartView)
    func getPercentageAvailability(timeFrom: String, timeTo: String, pages: Pages, lineChart: LineChartView, barChart: BarChartView, pieChart: PieChartView)
}

protocol MonitoringPageViewModelOutputs {
    var onDataFetch: (([Double]) -> Void)? { get set }
}

protocol MonitoringPageViewModelType {
    var inputs: MonitoringPageViewModelInputs { get set }
    var outputs: MonitoringPageViewModelOutputs { get set }
}

class MonitoringPageViewModel: MonitoringPageViewModelType, MonitoringPageViewModelInputs, MonitoringPageViewModelOutputs {
        
    var networking: Networking
    var device: Device
    var charts = ChartsModel()
    
    var inputs: MonitoringPageViewModelInputs { get { self } set {} }
    var outputs: MonitoringPageViewModelOutputs { get { self } set {} }

    var onDataFetch: (([Double]) -> Void)?
    
    init(device: Device, networking: Networking) {
        self.networking = networking
        self.device = device
    }
    
    func getPercentageAvailability(timeFrom: String, timeTo: String, pages: Pages, lineChart: LineChartView, barChart: BarChartView, pieChart: PieChartView) {
    
        let request = EnergyDataRequest(token: device.token,
                                        data: "",
                                        format: "",
                                        period: pages.timePeriod,
                                        from: timeFrom,
                                        to: timeTo)

        networking.post(url: "https://backend.merito.tech/api2-r/monitoring",
                        jsonBody: request,
                        onCompletion: {[weak self] (response: MonitoringResponse) in
            
            var chartData: [ProfileChartData] = []
            var statusData: [ChartDatasetStruct] = []
            
            switch pages {
            case .pageZero:

                let responseData = response.data
                                                
                for (responseData) in responseData {
                    /* create pairs of online and offline data to display stacked bars in chart */

                    var computedData: [[Double]] = [[responseData.timestamp, responseData.online], [responseData.timestamp ,responseData.offline]]

                    statusData.append(ChartDatasetStruct(energyData: nil, consumptionData: computedData, labelName: .none, unit: response.units.online))
                    computedData.removeAll()
                }
                self?.updateBarChart(chartData: statusData, chart: barChart, units: "sec")
                
            case .pageOne:
//                var timestamps: [Double] = []
                
                let timestampUptime: [[Double]] = response.data.map{
                    return [$0.timestamp, $0.uptime]
                }
  
                chartData.append(ProfileChartData(arrayOfValues: timestampUptime, phaseName: "", units: "%"))
                DispatchQueue.main.async {
                    self?.charts.updatePieChart(chart: pieChart, data: chartData)
                }

            case .pageTwo:
                let uptimes: [[Double]] = response.data.map {
                    return [$0.timestamp, $0.uptime]
                }
                                
                chartData.append(ProfileChartData(arrayOfValues: uptimes, phaseName: "", units: "%"))
                self?.updateLineChart(chartData: chartData, chart: lineChart, units: "%")
            }
            
        }, onError: { error in
            print(error)
        })
    }
    
    func prepareLineChart(chart: LineChartView) {
        charts.prepareLineChart(lineChart: chart, usedPercents: true)
    }
    
    func prepareBarChart(chart: BarChartView) {
        charts.prepareBarChart(barChart: chart)
    }
    
    func preparePieChart(chart: PieChartView) {
        charts.updatePieChart(chart: chart, data: [])
    }
    
    private func updateLineChart(chartData: [ProfileChartData], chart: LineChartView, units: String) {
        DispatchQueue.main.async {
            self.charts.updateLineChartWithMultipleLines(arrayOfProfileChartDataStructs: chartData, lineChart: chart, units: units, usingEpoch: true)
        }
    }
    
    private func updateBarChart(chartData: [ChartDatasetStruct], chart: BarChartView, units: String) {
        DispatchQueue.main.async {
            self.charts.updateBarChartData(fetchedData: chartData, chart: chart, units: units, stacked: true)}
    }
}
