//
//  LoginViewCoordinator.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 12/02 /2022.
//

import Foundation
import UIKit

protocol LoginViewCoordinatorType {
    func showDeviceListScreen(currentViewController: UIViewController)
}

class LoginViewCoordinator: LoginViewCoordinatorType {
    
    private weak var navigationController: UINavigationController?
    
    func showDeviceListScreen(currentViewController: UIViewController) {
//        let tabViewController = currentViewController.instantiateViewController(controllerIdentifier: "TapBarController")
//        currentViewController.currentController?.view.window?.rootViewController = tabViewController
//        currentViewController.currentController?.view.window?.makeKeyAndVisible()
    }
}
