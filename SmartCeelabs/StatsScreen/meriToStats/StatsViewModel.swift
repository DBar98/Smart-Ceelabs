//
//  StatsScreenViewModel.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 19/02/2022.
//

import Foundation
import UIKit

protocol StatsViewModelInputs {
    func goToDestinationViewController(viewController: StatsColectionElementEnum, parentVC: UIViewController, titleForVC: String)
}

protocol StatsViewModelOutputs {
//    var profileVCRequested: ((UIViewController) -> Void)? { get set }
}

protocol StatsViewModelType {
    var inputs: StatsViewModelInputs { get set }
    var outputs: StatsViewModelOutputs { get set }
}

class StatsViewModel: StatsViewModelType, StatsViewModelInputs, StatsViewModelOutputs {
    
    var inputs: StatsViewModelInputs { get { return self } set {} }
    var outputs: StatsViewModelOutputs { get { return self } set {} }
            
    var device: Device
    
    init(device: Device){
        self.device = device
    }
    
    lazy var profileVc: ProfileDetailViewController = {
        ProfileDetailViewController.instantiate()
    }()
    
    lazy var realTimeVC: RealTimeDetailsViewController = {
        RealTimeDetailsViewController.instantiate()
    }()
    
//    lazy var analyticsVC: AnalyticsDataViewController = {
//        AnalyticsDataViewController.instantiate()
//    }()
    
    func goToDestinationViewController(viewController: StatsColectionElementEnum, parentVC: UIViewController, titleForVC: String) {
        switch viewController {
        case .profile:
            profileVc.title = titleForVC
            profileVc.viewModel = ProfileDetailViewModel(device: device, networkingService: Networking(), chartsService: ChartsModel())
            parentVC.navigationController?.pushViewController(profileVc, animated: true)
        case .realTime:
            realTimeVC.viewModel = RealTimeViewModel(device: device, chartsService: ChartsModel())
            realTimeVC.title = titleForVC
            parentVC.navigationController?.pushViewController(realTimeVC, animated: true)
        case .analytics:
            let analyticsVC = AnalyticsDataViewController.instantiate()
            analyticsVC.title = titleForVC
            analyticsVC.viewModel = AnalyticsViewModel(device: device, networking: Networking(), chartsModel: ChartsModel())
            parentVC.navigationController?.pushViewController(analyticsVC, animated: true)
        }
    }
}
