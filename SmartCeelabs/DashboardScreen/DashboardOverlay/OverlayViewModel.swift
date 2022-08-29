//
//  OverlayViewModel.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 01/02/2022.
//

import Foundation
import RealmSwift

protocol OverlayViewModelOutputs {
    func updateDeviceName(deviceToken: String, deviceName: String)
}

class OverlayViewModel: OverlayViewModelOutputs {
        
    init(){
    }
    
    func updateDeviceName(deviceToken: String, deviceName: String) {
        guard let realm = try? Realm() else { return }

        let device = realm.objects(Device.self).filter("token = %@", deviceToken)

        if let device = device.first {
            try? realm.write {
                device.name = deviceName
            }
        }
    }
}
