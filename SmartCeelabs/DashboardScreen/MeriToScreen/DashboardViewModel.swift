//
//  DeviceDetailViewModel.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 18/01/2022.
//

import Foundation
import RealmSwift
import Charts
import UIKit

protocol DashboardViewModelInputs {
    func fetchDataFromWebSocket(deviceToken: String)
    func setupRealTimeCellValues(currentViewController: DashboardViewController)
    func stopFetchingDataFromWebSocket()
    func getDeviceCategories(token: String) -> [String]
    func setupStaticCellValues(viewController: DashboardViewController, token: String, timeFrom: String, dateInterval: String)
    func reloadReactiveEnergyChart(timeInterval: EnergyDataTimeIntervalsEnum, currentController: DashboardViewController, chartView: UIView, energyDataType: EnergyDataTypeEnum, selectedOutput: ReactiveEnergyOutputsEnum)
    func reloadActiveEnergyChart(timeInterval: EnergyDataTimeIntervalsEnum, currentController: DashboardViewController, chartView: UIView, energyDataType: EnergyDataTypeEnum)
    
    
    func fetchEnergyData(energyDataType: String, timeline: EnergyDataTimeIntervalsEnum, barChart: BarChartView, selectedDataType: EnergyDataOutputsEnum, controller: UIViewController, isFirstInitialized: Bool)
    func prepareChart(barChart: BarChartView)
}

protocol DashboardViewModelOutputs {
    var device: Device { get set }
    
    var barChart: BarChartView? { get set }
}

protocol DashboardViewModelType {
    var inputs: DashboardViewModelInputs { get set }
    var outputs: DashboardViewModelOutputs { get set }
}

class DashboardViewModel: DashboardViewModelInputs, DashboardViewModelOutputs, DashboardViewModelType, ChartViewDelegate {

    var inputs: DashboardViewModelInputs { get { self } set {} }
    var outputs: DashboardViewModelOutputs{ get { self } set {} }
    
    
    let realm: Realm
    var timer: Timer
    var activeBarChart: BarChartView
    var reactiveBarChart: BarChartView
    let networking: Networking
    var chartData: [ChartDatasetStruct] = []
    let chartModel: ChartsModel
    let apiProfileUrl: String = UrlEnum.profileDataUrl.rawValue
    var device: Device
    //
    var barChart: BarChartView?
    //
    
    init(deviceModel: Device){
        self.realm = try! Realm()
//        self.websocketService = WebSocketService()
        self.timer = Timer()
        self.activeBarChart = BarChartView()
        self.reactiveBarChart = BarChartView()
        self.networking = Networking()
        self.chartModel = ChartsModel()
        self.device = deviceModel
        
        self.activeBarChart.delegate = self
        self.reactiveBarChart.delegate = self
    }
    
    func getDeviceCategories(token: String) -> [String]{
        guard let device = getDeviceTypeByToken(token: self.device.token) else {return []}
        
        if device.type == 1 && device.autoLearn == false {
            return DeviceCategoryEnum.meriTo.category
        } else {
            return DeviceCategoryEnum.disconnector.category
        }
    }
    
    func fetchDataFromWebSocket(deviceToken: String){
        WebSocketService.shared.startFetchData(webSocketRequest: WebsocketRequest(deviceToken: self.device.token, state: true, data: true).stringRepresentation, wantSingleValueFromRequest: true, wantsOnlineStatus: false)
    }
    
    func stopFetchingDataFromWebSocket(){
        WebSocketService.shared.close()
    }
    
    func setupRealTimeCellValues(currentViewController: DashboardViewController){

        for cell in currentViewController.infoCollectionView.visibleCells as! [InfoCollectionCell] {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                guard let cellName = cell.nameLabel.text else {return}

                let cellNameEnum = DashboardRealTimeMenuEnum(rawValue: cellName)
                
                guard let cellNameEnum = cellNameEnum else { return }
                
                cell.cellImage.image = DashboardRealTimeMenuEnum(rawValue: cellName)?.image
                var cellValue: String = ""
                switch cellNameEnum {
                case .voltage:
                    cellValue = String(WebSocketSingleValueEnum.voltage(webSocketResponse: webSocketResponsesArray).realTimeValue) + "V"
                case .current:
                    cellValue = String(WebSocketSingleValueEnum.current(webSocketResponse: webSocketResponsesArray).realTimeValue) + "A"
                case .activePower:
                    cellValue = String(WebSocketSingleValueEnum.activePower(webSocketResponse: webSocketResponsesArray).realTimeValue) + "W"
                case .reactivePower:
                    cellValue = String(WebSocketSingleValueEnum.reactivePower(webSocketResponse: webSocketResponsesArray).realTimeValue) + "Wh"
                }
                cell.updateDisplayedValue(value: cellValue)
            })
        }
    }
    
    func setupStaticCellValues(viewController: DashboardViewController, token: String, timeFrom: String, dateInterval: String) {
        let request = ProfileDataRequest(token: self.device.token,
                                                 data: "I,U,P,S",
                                                 format: "H",
                                                 phase: "L1,L2,L3",
                                                 from: timeFrom,
                                                 to: Date().currentTimeInTimeStampAsString,
                                                 cumulative: "true")
        
        networking.post(url: apiProfileUrl,
                        jsonBody: request,
                        onCompletion: {[weak self] (response: Response) in
            
            guard let self = self else {return}
            
            switch response.status {
            case .ok :
                for cell in viewController.infoCollectionView.visibleCells as! [InfoCollectionCell] {
                    guard let cellName = cell.nameLabel.text else {return}
                    let cellNameEnum = DashboardRealTimeMenuEnum(rawValue: cellName)
                                        
//                    self.setupRealTimeCellValues(currentViewController: viewController)
                    switch cellNameEnum {
                    case .voltage:
                        self.setTopValuesForCell(cell: cell, responseData: response.data.u?.cumulative ?? [], units: response.units.u ?? "")
                        cell.dateInfo.text = dateInterval
                    case .current:
                        self.setTopValuesForCell(cell: cell, responseData: response.data.i?.cumulative ?? [], units: response.units.i ?? "")
                        cell.dateInfo.text = dateInterval
                    case .activePower:
                        self.setTopValuesForCell(cell: cell, responseData: response.data.p?.cumulative ?? [], units: response.units.p ?? "")
                        cell.dateInfo.text = dateInterval
                    case .reactivePower:
                        self.setTopValuesForCell(cell: cell, responseData: response.data.s?.cumulative ?? [], units: response.units.s ?? "")
                        cell.dateInfo.text = dateInterval
                    case .none:
                        self.setTopValuesForCell(cell: cell, responseData: response.data.u?.cumulative ?? [], units: response.units.u ?? "")
                    }
                }
                
            case .fail:
                print("Failed to fetch data.")
            }
        }, onError: { error in
            print(error)
        })
        
        
    }
    
    private func setTopValuesForCell(cell: InfoCollectionCell, responseData: [[Double]], units: String) {
        DispatchQueue.main.async {
            cell.maxValue.text = String(ProfileDetailPhaseInfoEnums
                                            .MAX(arrayOfValues: responseData)
                                            .getTopValue) + " \(units)"
            cell.minValue.text = String(ProfileDetailPhaseInfoEnums
                                            .MIN(arrayOfValues: responseData)
                                            .getTopValue) + " \(units)"
            cell.avgValue.text = String(ProfileDetailPhaseInfoEnums
                                            .AVG(arrayOfValues: responseData)
                                            .getTopValue) + " \(units)"
        }
       
    }
    
    func reloadActiveEnergyChart(timeInterval: EnergyDataTimeIntervalsEnum, currentController: DashboardViewController, chartView: UIView, energyDataType: EnergyDataTypeEnum) {
        var responseEnergyImport: [[Double]] = []
        var responseEnergyExport: [[Double]] = []
    
        let request = EnergyDataRequest(token: self.device.token,
                                        data: energyDataType.rawValue,
                                        format: "H",
                                        period: timeInterval.getTimePeriod.rawValue,
                                        from: timeInterval.getTimeInterval,
                                        to: Date().currentTimeInTimeStampAsString)
        
        self.networking.post(url: UrlEnum.energyDataUrl.rawValue, jsonBody: request, onCompletion: {[weak self] (response: EnergyDataResponse) in
            guard let self = self else {return}
            
            switch response.status {
            case .ok:
                
                responseEnergyImport = response.data.eI?.cum ?? []
                responseEnergyExport = response.data.eE?.cum ?? []
        
                self.chartData.removeAll()
                
                /*Place for serial global dispatchque*/
                let energyExportFiltered = ChartDatasetStruct(energyData: nil, consumptionData: responseEnergyExport, labelName: .energyExport, unit: response.units.eE ?? "wh")
                let energyImportFiltered = ChartDatasetStruct(energyData: nil, consumptionData: responseEnergyImport, labelName: .energyImport, unit: response.units.eI ?? "wh")
                    
                self.chartData.append(energyImportFiltered)
                self.chartData.append(energyExportFiltered)
                //get back to main and add chart to cell view
                DispatchQueue.main.async {
                    self.prepareBarChart(timestampData: self.chartData, chartView: chartView, barChart: self.activeBarChart)
                }
            case .fail:
                print("Data fetching error")
            }
        }, onError: { error in
            print("\(error)")
        })
    }
        
    
    func reloadReactiveEnergyChart(timeInterval: EnergyDataTimeIntervalsEnum, currentController: DashboardViewController, chartView: UIView, energyDataType: EnergyDataTypeEnum, selectedOutput: ReactiveEnergyOutputsEnum) {
        
        var responseQuadrantOne: [[Double]] = []
        var responseQuadrantTwo: [[Double]] = []
        var responseQuadrantThree: [[Double]] = []
        var responseQuadrantFour: [[Double]] = []
        
        let request = EnergyDataRequest(token: self.device.token,
                                        data: energyDataType.rawValue,
                                        format: "H",
                                        period: timeInterval.getTimePeriod.rawValue,
                                        from: timeInterval.getTimeInterval,
                                        to: Date().currentTimeInTimeStampAsString)
        
        self.networking.post(url: UrlEnum.energyDataUrl.rawValue, jsonBody: request, onCompletion: {[weak self] (response: EnergyDataResponse) in
            guard let self = self else {return}
            
            switch response.status {
            case .ok:
            
                responseQuadrantOne = response.data.q1?.cum ?? []
                responseQuadrantTwo = response.data.q2?.cum ?? []
                responseQuadrantThree = response.data.q3?.cum ?? []
                responseQuadrantFour = response.data.q4?.cum ?? []
                                
                self.chartData.removeAll()
                
                /*Place for serial global dispatchque*/
        
                let quadrantOneData = ChartDatasetStruct(energyData: nil, consumptionData: responseQuadrantOne, labelName: .Q1, unit: response.units.q1 ?? "wh")
                let quadrantTwoData = ChartDatasetStruct(energyData: nil, consumptionData: responseQuadrantTwo, labelName: .Q2, unit: response.units.q2 ?? "wh")
                let quadrantThreeData = ChartDatasetStruct(energyData: nil, consumptionData: responseQuadrantThree, labelName: .Q3, unit: response.units.q3 ?? "wh")
                let quadrantFourData = ChartDatasetStruct(energyData: nil, consumptionData: responseQuadrantFour, labelName: .Q4, unit: response.units.q4 ?? "wh")

                switch selectedOutput {
                case .Q1:
                    self.chartData.append(quadrantOneData)
                case .Q2:
                    self.chartData.append(quadrantTwoData)
                case .Q3:
                    self.chartData.append(quadrantThreeData)
                case .Q4:
                    self.chartData.append(quadrantFourData)
                }
//                self.chartData = [quadrantOneData, quadrantTwoData, quadrantThreeData, quadrantFourData]

                //get back to main and add chart to cell view
                DispatchQueue.main.async {
                    self.prepareBarChart(timestampData: self.chartData, chartView: chartView, barChart: self.reactiveBarChart)
                }
            case .fail:
                print("Data fetching error")
            }
        }, onError: { error in
            print("\(error)")
        })
    }
    
    func fetchEnergyData(energyDataType: String, timeline: EnergyDataTimeIntervalsEnum, barChart: BarChartView, selectedDataType: EnergyDataOutputsEnum, controller: UIViewController, isFirstInitialized: Bool) {
        
        if !isFirstInitialized {
            controller.showSpinner(onView: barChart)
        }
        let request = EnergyDataRequest(token: device.token,
                                        data: "E_E, E_I,Q1,Q2,Q3,Q4",
                                        format: "H",
                                        period: timeline.getTimePeriod.rawValue,
                                        from: timeline.getTimeInterval,
                                        to: Date().currentTimeInTimeStampAsString)
                
        networking.post(url: UrlEnum.energyDataUrl.rawValue,
                        jsonBody: request,
                        onCompletion: { [weak self] (response: EnergyDataResponse) in
            
            guard let self = self else { return }
            switch response.status {
            case .ok:
                var dataSet: [ChartDatasetStruct] = []

                let responseData = response.data.getDataByOutput(output: energyDataType)
                
                let energyExportFiltered = ChartDatasetStruct(energyData: nil, consumptionData: responseData?.cum, labelName: selectedDataType, unit: response.units.getDataByOutput(output: energyDataType) ?? "wh")
                
                dataSet = [energyExportFiltered]
                self.updateBarChart(timestampData: dataSet, barChart: barChart, units: energyExportFiltered.unit)
                controller.removeSpinner()
            case .fail:
                print("🚫 Fetch data proccess failed. 🚫")
                if (isFirstInitialized)  { controller.removeSpinner() }
            }
        }, onError: { error in
            print("🚫 Error occured: \(error) 🚫")
            if (isFirstInitialized)  { controller.removeSpinner() }
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
    
    private func prepareBarChart(timestampData: [ChartDatasetStruct], chartView: UIView, barChart: BarChartView){
        
        let yAxisFormatter: YAxisValueFormatter
        
        if timestampData.count != 0 {
            yAxisFormatter = YAxisValueFormatter(unit: timestampData[0].unit)
            barChart.leftAxis.valueFormatter = yAxisFormatter
        }
        
//        let yAxisFormatter = YAxisValueFormatter(unit: timestampData[0].unit)
        barChart.data = self.chartModel.prepareBarChartData(fetchedData: timestampData)
                
        barChart.frame = CGRect(x: 0, y: 0, width: chartView.frame.size.width, height: chartView.frame.size.height)
        barChart.xAxis.drawGridLinesEnabled = false
//        barChart.setVisibleXRangeMaximum(30)
        barChart.leftAxis.axisMinimum = 0
        barChart.rightAxis.drawLabelsEnabled = false
        barChart.barData?.barWidth = 0.3
        barChart.leftAxis.drawGridLinesEnabled = false
        barChart.rightAxis.drawGridLinesEnabled = false
        barChart.drawGridBackgroundEnabled = false
        barChart.xAxis.drawGridLinesBehindDataEnabled = false
        barChart.xAxis.labelPosition = .bottom
        barChart.rightAxis.axisLineWidth = 0
        barChart.xAxis.drawLabelsEnabled = false
        barChart.legend.enabled = false
        chartView.addSubview(barChart)
    }
    
    private func getDeviceTypeByToken(token: String) -> Device?{
        let devices =  self.realm.objects(Device.self)
        return devices.filter{$0.token == token}.first
    }
}

