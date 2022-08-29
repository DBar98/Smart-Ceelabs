//
//  TimelineViewModel.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 05/03/2022.
//

import Foundation
import Charts

protocol TimelineViewModelInputs {
    func fetchEnergyData(timeFrom: String, timeTo: String, barChart: BarChartView, relayIndex: Int)
    func prepareChart(barChart: BarChartView)
    func fetchDisconnector()
}

protocol TimelineViewModelOutputs {
    var barChart: BarChartView? { get set }
    var totalValue: (([(energyType: String, energyValue: String)]) -> Void)? { get set }
    var onDisconnectorFetch: ((DisconnectorModel) -> Void)? { get set }
    var onTimeArrayFetch: (([Double]) -> Void)? { get set }
}

protocol TimelineViewModelType {
    var inputs: TimelineViewModelInputs { get set }
    var outputs: TimelineViewModelOutputs { get set }
}

class TimelineViewModel: TimelineViewModelType, TimelineViewModelInputs, TimelineViewModelOutputs {
    var inputs: TimelineViewModelInputs { get { self } set {} }
    
    var outputs: TimelineViewModelOutputs { get { self } set {} }
    
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

    func fetchEnergyData(timeFrom: String, timeTo: String, barChart: BarChartView, relayIndex: Int) {
        let request = TimelineRequest(token: device.token,
                                      from: timeFrom,
                                      to: timeTo)
        
        networking.post(url: "https://backend.merito.tech/api2-r/disconnector/data",
                        jsonBody: request, onCompletion: {[weak self] (response: TimelineResponse) in
            var array: [[Double]] = []

            switch response.status {
            case .ok:
                guard let relayData = response.data.getDataByRelayIndex(idx: relayIndex) else { return }
                
                var timeArray: [Double] = []
                for relayData in relayData {
                    
                    //Collect timestamps when device was switched on for overlay purposes
                    if relayData.state == 1 {
                        timeArray.append(relayData.start)
                    }
                    
                    let timeArray: [Double] = [relayData.start, relayData.end, Double(relayData.state)]
                    array.append(timeArray)
                }
                
                self?.onTimeArrayFetch?(timeArray)
                DispatchQueue.main.async {
                        self?.chartModel.updateTimeLineCharts(timelineArray: array, chart: barChart)
                }
            
            case .fail:
                print("Timeline data failed.")
            }
            
        }, onError: { error in
            print(error)
        })
    }
    
    func fetchDisconnector() {
            let request = RelayRequest(token: device.token, power: "true", names: "true")

            networking.post(url: "https://backend.merito.tech/api2-r/disconnector/settings", jsonBody: request, onCompletion: { (response: RelayResponse) in
                switch response.status {
                case .ok:
                    
                    guard let data = response.data else { return }
                    let disconnector = DisconnectorModel(relay1: RelayModel(name: data.r1.name,
                                                                            energy: data.r1.power,
                                                                            state: false),
                                                        relay2: RelayModel(name: data.r2.name,
                                                                            energy: data.r2.power,
                                                                            state: false),
                                                        relay3: RelayModel(name: data.r3.name,
                                                                            energy: data.r3.power,
                                                                            state: false),
                                                        relay4: RelayModel(name: data.r4.name,
                                                                            energy: data.r4.power,
                                                                            state: false))
                    self.onDisconnectorFetch?(disconnector)
                    case .fail:
                    print("Relay data fetch failed")
                }
            }, onError: { (error) in
                print(error)
            })
    }
    
    func prepareChart(barChart: BarChartView) {
        self.barChart = chartModel.prepareBarChart(barChart: barChart)
    }
    
    var barChart: BarChartView?
    
    var totalValue: (([(energyType: String, energyValue: String)]) -> Void)?
    
    var onDisconnectorFetch: ((DisconnectorModel) -> Void)?

    var onTimeArrayFetch: (([Double]) -> Void)?
}
