//
//  DevicesCoordinator.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 11/02/2022.
//

import Foundation
import UIKit

protocol DevicesCoordinatorType {
    func start(parent: UIViewController)
    func showDeviceDetail(device: Device)
}

class DevicesCoordinator: DevicesCoordinatorType {
    func start(parent: UIViewController) {
//        guard let controller = DevicesViewController.instantiate() else { return }
//        controller.viewModel = DeviceViewModel(networking: Networking())
//        parent.navigationController?.pushViewController(controller, animated: true)
    }
    
    func showDeviceDetail(device: Device) {
        
    }
    
    
}
