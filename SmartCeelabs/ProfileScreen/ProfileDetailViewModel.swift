//
//  ProfileDetailViewModel.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 21/02/2022.
//

import Foundation
import KeychainSwift
import RealmSwift
import Charts
import UIKit
//import RxSwift

protocol ProfileDetailViewModelInputs {
    func fetchData(phases: [String], data: ProfileDataEnum, cumulative: String, timeFrom: String, timeTo: String, lineChart: LineChartView, currentController: UIViewController)
}

protocol ProfileDetailViewModelOutputs{
    var onDataFetch: (([ProfileChartData]) -> Void)? { get set }
    var devicePhases: Int? { get set }
//    var rxChartData: PublishSubject<[ProfileChartData]>? { get set }
}

protocol ProfileDetailViewModelType {
    var inputs: ProfileDetailViewModelInputs { get set }
    var outputs: ProfileDetailViewModelOutputs { get set }
}

class ProfileDetailViewModel: BaseViewModel, ProfileDetailViewModelType, ProfileDetailViewModelInputs, ProfileDetailViewModelOutputs {
//    var rxChartData: PublishSubject<[ProfileChartData]>?
    
    
    var inputs: ProfileDetailViewModelInputs { get { return self } set {} }
    var outputs: ProfileDetailViewModelOutputs { get { return self } set {} }
    
    var onDataFetch: (([ProfileChartData]) -> Void)?
    var devicePhases: Int?
    
    var device: Device
    var networking: Networking
    let chartsModel: ChartsModel
    let keychain = KeychainSwift()
    var profileUrl = UrlEnum.profileDataUrl.rawValue
    var retryAttempt: Int = 0
    
    init(device: Device, networkingService: Networking, chartsService: ChartsModel){
        self.device = device
        self.networking = networkingService
        self.chartsModel = chartsService
        devicePhases = device.phaseUse
    }
   
    override func retryLogCurrentUser(userEmail: String?, hashedPassword: String?, url: String, onCompletion: @escaping () -> ()) {
        super.retryLogCurrentUser(userEmail: userEmail, hashedPassword: hashedPassword, url: url, onCompletion: onCompletion)
    }
    
    func fetchData(phases: [String], data: ProfileDataEnum, cumulative: String, timeFrom: String, timeTo: String, lineChart: LineChartView, currentController: UIViewController){

        currentController.showSpinner(onView: lineChart)

        let request = ProfileRequest(token: device.token,
                                     data: data.getDataShortuct,
                                     format: "H",
                                     phase: "L1, L2, L3",
                                     cumulative: cumulative,
                                     from: timeFrom,
                                     to: timeTo)
        
        networking.post(url: profileUrl,
                        jsonBody: request,
                        onCompletion: { [weak self] (response: Response) in
            guard let self = self else { return }
            
            switch response.status {
            case.ok:
                
                var chartData: [ProfileChartData] = []
                var specifiedData = self.getSpecificData(dataType: data, response: response, phases: phases)
                chartData = specifiedData.0
                self.updateLineChartView(chartData: chartData, lineChart: lineChart, units: specifiedData.1, controller: currentController)
                
                //RX SWIFT IMPL
//                self.rxChartData = PublishSubject<[ProfileChartData]>()
//
//                self.rxChartData?.onNext([ProfileChartData(arrayOfValues: [[0.0]], phaseName: "L1", units: "AAA")])
//                /*
//                 Let know observer data has changed
//                 */
//                self.rxChartData?.onCompleted()
//
                self.onDataFetch?(chartData)                
                currentController.removeSpinner()
            case .fail:
                print("Failed to fetch data.")
            }
        }, onError: {
            print($0)
        })
    }
    
    private func getSpecificData(dataType: ProfileDataEnum, response: Response, phases: [String]) -> (data: [ProfileChartData], unit: String){
        var chartDataArray: [ProfileChartData] = []
        var units: String = ""
        
        switch dataType {
        case .voltage:
            for phase in phases {
                chartDataArray.append(ProfileChartData(arrayOfValues: response.data.u?.getPahse(phase: phase) ?? [], phaseName: phase, units: response.units.u ?? ""))
                units = response.units.u ?? ""
            }
        case .current:
            for phase in phases {
                chartDataArray.append(ProfileChartData(arrayOfValues: response.data.i?.getPahse(phase: phase) ?? [], phaseName: phase, units: response.units.i ?? ""))
                units = response.units.i ?? ""

            }
        case .apparentPower:
            for phase in phases {
                chartDataArray.append(ProfileChartData(arrayOfValues: response.data.s?.getPahse(phase: phase) ?? [], phaseName: phase, units: response.units.s ?? ""))
                units = response.units.s ?? ""
            }
        case .reactivePower:
            for phase in phases {
                chartDataArray.append(ProfileChartData(arrayOfValues: response.data.q?.getPahse(phase: phase) ?? [], phaseName: phase, units: response.units.q ?? ""))
                units = response.units.q ?? ""
            }
        case .activePower:
            for phase in phases {
                chartDataArray.append(ProfileChartData(arrayOfValues: response.data.p?.getPahse(phase: phase) ?? [], phaseName: phase, units: response.units.p ?? ""))
                units = response.units.p ?? ""
            }
        case .energyImport:
            for phase in phases {
                chartDataArray.append(ProfileChartData(arrayOfValues: response.data.e_i?.getPahse(phase: phase) ?? [], phaseName: phase, units: response.units.e_i ?? ""))
                units = response.units.e_i ?? ""
            }
        case .energyExport:
            for phase in phases {
                chartDataArray.append(ProfileChartData(arrayOfValues: response.data.e_e?.getPahse(phase: phase) ?? [], phaseName: phase, units: response.units.e_e ?? ""))
                units = response.units.e_e ?? ""
            }
        }
        return (chartDataArray, units)
    }
    
    private func updateLineChartView(chartData: [ProfileChartData], lineChart: LineChartView, units: String, controller: UIViewController) {
        DispatchQueue.main.async {
            self.chartsModel.updateLineChartWithMultipleLines(arrayOfProfileChartDataStructs: chartData, lineChart: lineChart, units: units, usingEpoch: false)
        }
    }
    
    private func updateDeviceFterRetry(mac: String) {
        guard let realm = try? Realm() else { return }
        
        let newDevice = realm.objects(Device.self).where {
            $0.mac == device.mac
        }.first
        
        guard let newDevice = newDevice else {
            return
        }

        self.device = newDevice
    }
}
