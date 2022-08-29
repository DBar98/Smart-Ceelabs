//
//  DeviceSearchViewModel.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 21/03/2022.
//

import Foundation
import RealmSwift
import UIKit

protocol DeviceSearchViewModelInputs {
    func getDevicesByName(name: String)
    func pushToDeviceSearchViewController(parent: UIViewController, detailVC: DeviceDetailViewController, device: Device)
}

protocol DeviceSearchViewModelOutputs {
    var onDeviceFetch:  (([Device]) -> ())? { get set }
}

protocol DeviceSearchViewModelType {
    var inputs: DeviceSearchViewModelInputs { get set }
    var outputs: DeviceSearchViewModelOutputs { get set }
}

class DeviceSearchViewModel: DeviceSearchViewModelInputs, DeviceSearchViewModelOutputs, DeviceSearchViewModelType {
   
    func getDevicesByName(name: String) {
        guard let realm = try? Realm() else { return }
        let deviceDto = realm.objects(Device.self).filter("name contains[cd] %@", name)
        self.onDeviceFetch?(deviceDto.map {
            $0
        })
    }
    
    func pushToDeviceSearchViewController(parent: UIViewController, detailVC: DeviceDetailViewController, device: Device) {
        detailVC.viewModel = DeviceDetailViewModel(device: device)
        parent.presentingViewController?.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    var onDeviceFetch: (([Device]) -> ())?
    
    var inputs: DeviceSearchViewModelInputs { get { self } set {} }
    
    var outputs: DeviceSearchViewModelOutputs { get { self } set {} }
    
    init() {
    }
}
