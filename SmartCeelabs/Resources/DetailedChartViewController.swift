//
//  DetailedChartViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 07/04/2022.
//

import UIKit

class DetailedChartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func showDetailOverlay(value: String, time: Double, timeFormat: TimeFormat, unit: String) {
        let slideVC = DataDetailViewController()
        slideVC.time = time
        slideVC.value = value
        slideVC.timeFormat = timeFormat
        slideVC.unit = unit
        
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        self.present(slideVC, animated: true, completion: nil)
    }

}

// MARK: Transition view settings
extension DetailedChartViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationVC = PresentationController(presentedViewController: presented, presenting: presenting)
        presentationVC.presentationHeight = .low
        
        return presentationVC
    }
}
