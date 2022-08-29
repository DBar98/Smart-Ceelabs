//
//  OverlayView.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 28/01/2022.
//

import UIKit

protocol OverlayViewDelegate: AnyObject {
    func saveButtonPressed(deviceName: String)
}

class OverlayView: UIViewController {
    @IBOutlet weak var slideIndicator: UIView!
    @IBOutlet weak var deviceNameField: UITextField!
    @IBOutlet weak var macAddress: UILabel!
    @IBOutlet weak var latitudeField: UITextField!
    @IBOutlet weak var longitutdeField: UITextField!
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    var deviceToken: String?
    var viewModel: OverlayViewModelOutputs?
    weak var overlayDelegate: OverlayViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = OverlayViewModel()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        setupUI()
    }
    
    func setupUI(){
        slideIndicator.roundCorners(.allCorners, radius: 10)
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    
    @IBAction func cencelButtonPresse(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let deviceNameFieldText = deviceNameField.text else {
            return
        }
        overlayDelegate?.saveButtonPressed(deviceName: deviceNameFieldText)
        viewModel?.updateDeviceName(deviceToken: deviceToken ?? "", deviceName: deviceNameFieldText)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        longitutdeField.text = ""
        latitudeField.text = ""
        deviceNameField.text = ""
    }
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
}
