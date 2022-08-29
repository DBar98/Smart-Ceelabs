//
//  DeviceViewModel.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 15/01/2022.
//

import Foundation
import RealmSwift
import SwiftUI

protocol DeviceViewModelInputs {
    func getUserDevicesHierarchy()
    func goToDeviceDetailController(parentViewController: UIViewController, strucutredDevice: StructuredDevice?, realmDevice: Device?)
    func updateDeviceDtoNames(structuredDevices: [[StructuredDevice]])
    func getDeviceDtoByDeviceMac(mac: String) -> Device?
    func getFavouriteDevices(structuredDevices: [StructuredDevice]) -> [Device]
    func fetchDevicesOnlineState()
    func stopFetchingDataFromWebSocket()
}

protocol DeviceViewModelOutputs {
    var onStructuredDeviceFetch: (([String: [StructuredDevice]]) -> Void)? { get set }
    var onDeviceStatusesFetch: (([DeviceOnlineStatusResponse]) -> ())? { get set } // deviceMac and online status
}

protocol DeviceViewModelType {
    var inputs: DeviceViewModelInputs { get set }
    var outputs: DeviceViewModelOutputs { get set }
}

class DeviceViewModel: DeviceViewModelInputs, DeviceViewModelOutputs, DeviceViewModelType {

    var inputs: DeviceViewModelInputs { get { return self } set {} }
    var outputs: DeviceViewModelOutputs { get { return self } set {} }
    
    var onStructuredDeviceFetch: (([String : [StructuredDevice]]) -> Void)?
    var onDeviceStatusesFetch: (([DeviceOnlineStatusResponse]) -> ())?
    
    let realm: Realm
    var currentController: UIViewController?
    let networkingService: Networking
    let defaults = UserDefaults.standard
    let websocketService = WebSocketService.shared

    init(){
        self.realm = try! Realm()
        self.networkingService = Networking()
    }
    
    public func getUserDevicesByGivenType(type: DeviceType) -> [Device]{
        let devices =  self.realm.objects(Device.self)
        return devices.filter{$0.type == type.rawValue}
    }
    
    func getUserDevicesHierarchy() {
        guard let userToken = defaults.string(forKey: "userToken") else { return }
        let request = UserDevicesHierarchyRequest(token: userToken)
        networkingService.post(url: "https://backend.merito.tech/api2-r/facility/devices-hierarchy", jsonBody: request, onCompletion: {
            [weak self] (response: UserDevicesHierarchyResponse) in
            guard let self = self else {return}
            
            switch response.status {
            case .ok:
                self.onStructuredDeviceFetch?(self.getStructuredDevices(response: response.data))
            case .fail:
                print("‼️ Failed to fetch data. ‼️")
            }
        }, onError: {
            (error) in
            print("🚫 Error occured: \(error.localizedDescription)🚫")
        })
    }
    
    
    
    var devicePlace: [String] = []
    
    private func getStructuredDevices(response: HierarchyData) -> [String: [StructuredDevice]] {
        var buildingDeviceDict = [String: [StructuredDevice]]()
        var structuredDevices: [StructuredDevice] = []
        
        var unknownBuildingDevices: [StructuredDevice] = []
        
        
        for node in response.nodes {

            //guard let nodeChildren = node.children else { return [:] }
            if let nodeChildren = node.children {
                self.prepareStructuredDevices(array: nodeChildren, nodeName: node.title ?? "", isRecursive: false, structuredDevices: &structuredDevices)
                buildingDeviceDict.updateValue(structuredDevices, forKey: node.title ?? "")
            } else {
                unknownBuildingDevices.append(StructuredDevice(devicesGroup: "Untitled", devicePlace: "", deviceName: node.title ?? "" , deviceMac: node.data?.mac ?? ""))
            }
            if unknownBuildingDevices.count != 0 {
                buildingDeviceDict["Unknown Building"] = unknownBuildingDevices
            }
        }
        return buildingDeviceDict
    }
    
    private func prepareStructuredDevices(array: [NodeChild], nodeName: String, isRecursive: Bool, structuredDevices: inout [StructuredDevice]){
        var nodeChildren = array

        if !isRecursive {
            structuredDevices = []
        }
        //Iterate over each main node
        for child in nodeChildren {
            if !isRecursive {
                devicePlace.removeAll()
                let childTitle = child.title ?? ""
                devicePlace.append(childTitle)
            }
            
            if child.isLeaf != nil {
                if let childData = child.data {
                    let structuredDevice = StructuredDevice(devicesGroup: nodeName,
                                                        devicePlace: devicePlace.first ?? "",
                                                        deviceName: child.title ?? "",
                                                        deviceMac: childData.mac ?? ""
                    )
                    structuredDevices.append(structuredDevice)
                }
            } else if child.children != nil{
                nodeChildren = child.children ?? nodeChildren
                self.prepareStructuredDevices(array: nodeChildren, nodeName: nodeName, isRecursive: true, structuredDevices: &structuredDevices)
            }
        }
    }

    func goToDeviceDetailController(parentViewController: UIViewController, strucutredDevice: StructuredDevice?, realmDevice: Device?) {
        var device: Device?
        
        if let structuredDevice = strucutredDevice {
            device = getDeviceFromStructuredDevice(structuredDevice: structuredDevice)
        } else {
            device = realmDevice
        }
        
        guard let device = device else { return }
        
        let deviceDetailVC = DeviceDetailViewController.instantiate()
        deviceDetailVC?.viewModel = DeviceDetailViewModel(device: device)
        deviceDetailVC?.settingsViwModel = DeviceSettingsViewModel(device: device)
        parentViewController.navigationController?.pushViewController(deviceDetailVC ?? UIViewController(), animated: false)
      
    }
    
    func getDeviceFromStructuredDevice(structuredDevice: StructuredDevice) -> Device? {
        guard let realm = try? Realm() else { return nil}
        let devices = realm.objects(Device.self).where {
            $0.mac == structuredDevice.deviceMac
        }
       
        return devices.first
    }
    
    func getFavouriteDevices(structuredDevices: [StructuredDevice]) -> [Device] {
        var devices: Set<Device> = []
        guard let realm = try? Realm() else { return []}

        
        devices.removeAll()
        for structuredDevice in structuredDevices {
            let realmDevices = realm.objects(Device.self).where {
                $0.mac == structuredDevice.deviceMac
            }
            
            if let device = realmDevices.first {
                devices.insert(device)
            }
        }
    
        return devices.filter {
            $0.favourite == true
        }
    }
    
   func updateDeviceDtoNames(structuredDevices: [[StructuredDevice]]) {
       guard let realm = try? Realm() else { return }
       let structuredDevicesArray = structuredDevices.flatMap {
           $0
       }
       for structuredDevice in structuredDevicesArray {
          
           let deviceDto = realm.objects(Device.self).where {
               $0.mac == structuredDevice.deviceMac
          }
           
        if let deviceDto = deviceDto.first {
              try? realm.write {
                  deviceDto.name = structuredDevice.deviceName
              }
          }
       }
    }
    
    func fetchDevicesOnlineState() {
        guard let userToken = defaults.string(forKey: "userToken") else { return }
        let wsRequest = DeviceOnlineStatusRequest(userToken: userToken, state: true)
        
        guard let realm = try? Realm() else { return }
        
        websocketService.wantsOnlineStatus = true
        websocketService.deviceCount = realm.objects(Device.self).count

        websocketService.startFetchData(webSocketRequest: wsRequest.stringRepresentation,
                                        wantSingleValueFromRequest: false,
                                        wantsOnlineStatus: true)
        
        websocketService.onlineStatusDataReady = { [weak self] deviceStatuses in
            self?.onDeviceStatusesFetch?(deviceStatuses)
//            self?.websocketService.close()
        }
    }
    
    func stopFetchingDataFromWebSocket() {
        WebSocketService.shared.wantsOnlineStatus = false
        WebSocketService.shared.close()
    }
    
    func getDeviceDtoByDeviceMac(mac: String) -> Device?{
        guard let realm = try? Realm() else { return nil }
        let deviceDto = realm.objects(Device.self).where {
            $0.mac == mac
        }
        return deviceDto.first
    }
    
    func getDeviceByToken(token: String) -> Device?{
        let devices =  self.realm.objects(Device.self)
        return devices.filter{$0.token == token}.first
    }
}
