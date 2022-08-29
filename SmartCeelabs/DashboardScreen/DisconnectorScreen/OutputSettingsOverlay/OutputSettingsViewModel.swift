//
//  OutputSettingsViewModel.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 10/04/2022.
//

import Foundation

protocol OutputSettingsViewModelInputs {
    func changeOutputName(disconnector: DisconnectorTableModel)
}

protocol OutputSettingsViewModelType {
    var inputs: OutputSettingsViewModelInputs { get set }
}

class OutputSettingsViewModel: OutputSettingsViewModelInputs, OutputSettingsViewModelType {
    var inputs: OutputSettingsViewModelInputs { get { self } set {} }

    let networking: Networking
    var device: Device
    
    init(networking: Networking, device: Device) {
        self.networking = networking
        self.device = device
    }
    
    func changeOutputName(disconnector: DisconnectorTableModel) {

        let outputs = OutputNames(R1: disconnector.relay1,
                                  R2: disconnector.relay2,
                                  R3: disconnector.relay3,
                                  R4: disconnector.relay4)
        
        let request = OutputSettingsRequest(token: device.token,
                                            names: outputs)
        
        networking.post(url: "https://backend.merito.tech/api2-w/disconnector/settings", jsonBody: request, onCompletion: {[weak self] (response: RelayResponse) in
            
        
            switch response.status {
            case .ok:
                print(response.message)
                case .fail:
                print("Relay name cannot be changed")
            }
        }, onError: { (error) in
            print(error)
        })
    }
}
