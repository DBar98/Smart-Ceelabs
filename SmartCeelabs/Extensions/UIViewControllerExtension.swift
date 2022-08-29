//
//  UIViewControllerExtension.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 11/04/2022.
//

import UIKit

fileprivate var vSpinner: UIView?
fileprivate var spinnerCreated: Bool = false

extension UIViewController {

    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .large)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        if !spinnerCreated {
            DispatchQueue.main.async {
                spinnerView.addSubview(ai)
                onView.addSubview(spinnerView)
                spinnerCreated = true
            }
            vSpinner = spinnerView
        }
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
            spinnerCreated = false
        }
    }
}
