//
//  BaseViewModel.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 30/03/2022.
//

import Foundation
import RealmSwift

class BaseViewModel {
    
    let networkingService = Networking()
    
    func retryLogCurrentUser(userEmail: String?, hashedPassword: String?, url: String,  onCompletion: @escaping () -> ()){
        
        guard let userEmail = userEmail, let hashedPassword = hashedPassword else {
            return
        }

        
        let credentials = LocalLoginCredentials(login: userEmail,
                                                password: hashedPassword)
        networkingService.post(url: url,
                               jsonBody: credentials,
                               onCompletion: { [weak self] (response: LoginResponse) in
            guard let self = self else { return }

            switch response.status {
            case .ok:
               
                guard let data = response.data else {return}
                
                //save user devices - new way by update
                self.updateUserDevices(devices: data)
                onCompletion()
                //old way by delete and add
                //self.saveAllUserDevices(devices: data)
                
            case .fail:
              print("failed")
            }
        }, onError: { error in
            print("🚫 Error occured: \(error)🚫")
        })
    }
    
    func updateUserDevices(devices: [LoginData]) {
        guard let realm = try? Realm() else { return }
        
        let realmDevices = realm.objects(Device.self)
        let realmDevicesMac: [String] = realmDevices.map { $0.mac }
        let fetchedDevicesMac: [String] = devices.map { $0.mac }
        
         fetchedDevicesMac.map {
            let fetchedMac = $0
            if !realmDevicesMac.contains(fetchedMac) {
                //find missing device in newly fetched devices
                let newDevice = devices.filter {
                    $0.mac == fetchedMac
                }.first
                
                guard let newDevice = newDevice else { return }
                
                //add newly fetched device
                realm.beginWrite()

                let deviceToAdd = Device()
                deviceToAdd.token = newDevice.token
                deviceToAdd.name = newDevice.mac
                deviceToAdd.mac = newDevice.mac
                deviceToAdd.autoLearn = ((newDevice.nilm?.autoLearn) != nil)
                deviceToAdd.owner = newDevice.owner
                deviceToAdd.lora = newDevice.lora ?? false
                deviceToAdd.phaseUse = newDevice.phaseUse ?? 0
                deviceToAdd.process = ((newDevice.nilm?.process) != nil)
                deviceToAdd.type = newDevice.type
                
                realm.add(deviceToAdd)
                try? realm.commitWrite()
            } else { // when device already saved in realm, then update fields
            //find realm device
                let realmDevice = realmDevices.filter {
                    $0.mac == fetchedMac
                }.first
                
                let newDevice = devices.filter {
                    $0.mac == fetchedMac
                }.first
                
                guard let realmDevice = realmDevice, let newDevice = newDevice else {
                    return
                }
                try? realm.write {
                    realmDevice.mac = newDevice.mac
                    realmDevice.token = newDevice.token
                }
            }
        }
    }
}
