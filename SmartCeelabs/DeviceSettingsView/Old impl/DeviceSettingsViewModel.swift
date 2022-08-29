//
//  DeviceSettingsViewModel.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 28/03/2022.
//

import Foundation
import RealmSwift

protocol DeviceSettingsViewModelInputs {
    func updateDeviceCoordinates(latitude: String, longitude: String)
}

protocol DeviceSettingsViewModelOutputs {
    var device: Device? { get set }
}

protocol DeviceSettingsViewModelType{
    var inputs: DeviceSettingsViewModelInputs { get set }
    var outputs: DeviceSettingsViewModelOutputs { get set }
}

class DeviceSettingsViewModel: DeviceSettingsViewModelInputs, DeviceSettingsViewModelOutputs, DeviceSettingsViewModelType {
    
    var device: Device?
    
    var inputs: DeviceSettingsViewModelInputs { get { self } set {} }
    var outputs: DeviceSettingsViewModelOutputs { get { self } set {} }

    init(device: Device) {
        self.device = device
    }
    
    func updateDeviceCoordinates(latitude: String, longitude: String) {
        guard let realm = try? Realm() else { return }
        
        guard let device = device else {
            return
        }

        let deviceResult = realm.objects(Device.self).where {
            $0.mac == device.mac
        }.first
        
        guard let deviceResult = deviceResult else { return }
        
        try? realm.write {
            deviceResult.latitude = Double(latitude) ?? 0
            deviceResult.longitude = Double(longitude) ?? 0
        }
        
    }
    
}
