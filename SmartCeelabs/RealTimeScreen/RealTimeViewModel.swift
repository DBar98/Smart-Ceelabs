//
//  RealTimeViewModel.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 22/01/2022.
//

import Foundation
import Charts

protocol RealTimeViewModelInputs {
    func fetchDataFromWebSocket()
    func viewDidLoad()
    func updateRealTimeChart(data: RealTimeDetailsEnumResponse, phasesArray: [String], lineChart: LineChartView, title: String)
}

protocol RealTimeViewModelOutputs {
    var numerOfAvailablePhases: Int? { get set }
}

protocol RealTimeViewModelType {
    var inputs: RealTimeViewModelInputs { get set }
    var outputs: RealTimeViewModelOutputs { get set }
}

class RealTimeViewModel: RealTimeViewModelType, RealTimeViewModelInputs, RealTimeViewModelOutputs {
    
    var numerOfAvailablePhases: Int?
    
    var outputs: RealTimeViewModelOutputs { get { self } set {} }
    var inputs: RealTimeViewModelInputs { get { self } set {} }
    
    var device: Device
    var chartsService: ChartsModel
    
    init(device: Device, chartsService: ChartsModel){
        self.device = device
        self.chartsService = chartsService
    }
    
    func viewDidLoad() {
        numerOfAvailablePhases = device.phaseUse
    }
    
    func fetchDataFromWebSocket() {
        let webSocketRequest = WebsocketRequest(deviceToken: self.device.token, state: true, data: true).stringRepresentation
        WebSocketService.shared.startFetchData(webSocketRequest: webSocketRequest, wantSingleValueFromRequest: false, wantsOnlineStatus: false)
    }
    
    func stopFetchingDataFromWebSocket(){
        WebSocketService.shared.close()
    }
    
    func updateRealTimeChart(data: RealTimeDetailsEnumResponse, phasesArray: [String], lineChart: LineChartView, title: String) {
        DispatchQueue.main.async {
            self.chartsService.updateRealTimeChartEntries(realTimeDetailsChartResponse: data,
                                                          arrayOfChosenPhases: phasesArray,
                                                          lineChart: lineChart,
                                                          units: ProfileDataEnum(rawValue: title)?.getBaseUnits ?? "")
        }
    }
}
