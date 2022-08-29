//
//  DeviceDetailViewModel.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 11/02/2022.
//

import Foundation
import UIKit
import RealmSwift

protocol DeviceDetailViewModelInputs {
    func viewDidLoad()
//    func changeViewInViewContainer(parentViewController: UIViewController, viewsToHide: [ViewController]) -> [ContainerViewController]
}

protocol DeviceDetailViewModelOutputs {
    var getContainerViewControllers: [ContainerViewController]? { get set }
}

protocol DeviceDetailViewModelType {
    var inputs: DeviceDetailViewModelInputs { get set }
    var outputs: DeviceDetailViewModelOutputs { get set }
}

class DeviceDetailViewModel: DeviceDetailViewModelInputs, DeviceDetailViewModelOutputs, DeviceDetailViewModelType {
   
    var outputs: DeviceDetailViewModelOutputs { get { self } set {} }
    var inputs: DeviceDetailViewModelInputs { get { self } set {} }
    
    let networking: Networking
    let device: Device
    
    init(device: Device){
        self.networking = Networking()
        self.device = device
    }
    
    func viewDidLoad() {
        getContainerViewControllers = self.containers
    }
    
    var containers: [ContainerViewController] {
        get {
            let deviceType = DeviceCategoryEnum(rawValue: device.type)
            switch deviceType {
            case .meriTo:
                let dashboardVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
                dashboardVC.viewModel = DashboardViewModel(deviceModel: device)
                
                let statsVC = UIStoryboard(name: "StatsScreen", bundle: nil).instantiateViewController(withIdentifier: "StatsViewController") as! StatsViewController
                statsVC.viewModel = StatsViewModel(device: device)
                
                let monitoringVC = MonitoringViewController.instantiate()
                monitoringVC.viewModel = MonitoringViewModel(device: device, networking: networking)
                
                return [dashboardVC, statsVC, monitoringVC]
            case .disconnector :
                let dashboardVC = UIStoryboard(name: "Disconnector", bundle: nil).instantiateViewController(withIdentifier: "DisconnectorViewController") as! DisconnectorViewController
                dashboardVC.viewModel = DisconnectorViewModel(networking: Networking(), device: device)
                dashboardVC.slideViewModel = RelayActionViewModel(device: device)
                dashboardVC.outputOverlayViewModel = OutputSettingsViewModel(networking: Networking(), device: device)
                
                let timelineVC = TimelineViewController.instantiate()
                timelineVC.viewModel = TimelineViewModel(device: device, networking: Networking(), chartsModel: ChartsModel())
                
                let monitoringVC = MonitoringViewController.instantiate()
                monitoringVC.viewModel = MonitoringViewModel(device: device, networking: networking)
                return [dashboardVC, timelineVC, monitoringVC]
            case .none:
                lazy var containerViewControllers: [ContainerViewController] = {
                    let dashboardVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
                    let realTimeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RealTimeViewController") as! RealTimeViewController
                    let analyticsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AnalyticsViewController") as! AnalyticsViewController
                    return [dashboardVC, realTimeVC, analyticsVC]
                }()
            }
            return []
        }
    }
    
    func updateDeviceFavouriteState(device: Device) {
        let currentState: Bool = device.favourite
        guard let realm = try? Realm() else { return }
        
        let realmDevice = realm.objects(Device.self).filter {
            $0.mac == device.mac
        }.first
        try? realm.write {
            realmDevice?.favourite = !currentState
        }
    }
    
    var getContainerViewControllers: [ContainerViewController]?

}
