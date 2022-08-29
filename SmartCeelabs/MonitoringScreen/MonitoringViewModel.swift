//
//  MonitoringViewModel.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 09/03/2022.
//

import Foundation

protocol MonitoringViewModelOutputs {
    var pageViewModel: MonitoringPageViewModelType? { get set }
}

protocol MonitoringViewModelInputs {
    func viewDidLoad()
}

protocol MonitoringViewModelType {
    var outputs: MonitoringViewModelOutputs { get set }
    var inputs: MonitoringViewModelInputs { get set }
}


class MonitoringViewModel: MonitoringViewModelType, MonitoringViewModelOutputs, MonitoringViewModelInputs {
    
    var outputs: MonitoringViewModelOutputs { get { self } set { } }
    var inputs: MonitoringViewModelInputs { get { self } set { } }

    var pageViewModel: MonitoringPageViewModelType?
    
    var networking: Networking
    var device: Device
    
    init(device: Device, networking: Networking){
        self.networking = networking
        self.device = device
    }
    
    func viewDidLoad() {
        pageViewModel = MonitoringPageViewModel(device: device, networking: networking)
    }
    
}
