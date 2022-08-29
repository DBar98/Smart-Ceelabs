//
//  DisconnectorViewModel.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 04/03/2022.
//

import Foundation

protocol DisconnectorViewModelType {
    var inputs: DisconnectorViewModelInputs { get set }
    var outputs: DisconnectorViewModelOutputs { get set }
}

protocol DisconnectorViewModelInputs {
    func fetchDataFromWebSocket()
    func fetchRelayData()
    func stopDataFetch()
    func changeRelayState(disconnector: DisconnectorModel) 
}

protocol DisconnectorViewModelOutputs {
    var device: Device { get set }
    var onDisconnectorFetch: ((DisconnectorModel) -> Void)? { get set }
}

class DisconnectorViewModel: DisconnectorViewModelInputs, DisconnectorViewModelOutputs, DisconnectorViewModelType {

    var inputs: DisconnectorViewModelInputs { get { self } set {} }
    
    var outputs: DisconnectorViewModelOutputs { get { self } set {} }
    
    
    var onDisconnectorFetch: ((DisconnectorModel) -> Void)?
    let networking: Networking
    var device: Device
    
    init(networking: Networking, device: Device) {
        self.networking = networking
        self.device = device
    }
    
    func fetchDataFromWebSocket(){
        let request = DisconnectorWSRequest(deviceToken: self.device.token,
                                            data: true).stringRepresentation
        //At first close old connection
        //This call causes problems when is used in DeviceViewModel 
        WebSocketService.shared.close()
        WebSocketService.shared.startFetchData(webSocketRequest: request, wantSingleValueFromRequest: true, wantsOnlineStatus: false)
    }
    
    func stopFetchingDataFromWebSocket(){
        WebSocketService.shared.close()
    }
    
    func stopDataFetch() {
        WebSocketService.shared.close()
    }
    
    func fetchRelayData() {

        let request = RelayRequest(token: device.token, power: "true", names: "true")

        networking.post(url: "https://backend.merito.tech/api2-r/disconnector/settings", jsonBody: request, onCompletion: {[weak self] (response: RelayResponse) in
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
                    self?.onDisconnectorFetch?(disconnector)
                case .fail:
                print("Relay data fetch failed")
            }
        }, onError: { (error) in
            print(error)
        })
    }
    
    func changeRelayState(disconnector: DisconnectorModel) {
                
        let request = DisconnectorStateRequest(token: self.device.token,
                                               relay_1: disconnector.relay1.state,
                                               relay_2: disconnector.relay2.state,
                                               relay_3: disconnector.relay3.state,
                                               relay_4: disconnector.relay4.state)
        
        self.networking.post(url: "https://backend.merito.tech/api2-w/disconnector/set-relay",
                             jsonBody: request,
                             onCompletion: {[weak self] (response: RelayResponse) in
            switch response.status {
            case .ok :
                print(response.message ?? "")
            case .fail:
                print(response.message ?? "")
            }
            
        }, onError: { error in
            print(error)
        })
    }
}
