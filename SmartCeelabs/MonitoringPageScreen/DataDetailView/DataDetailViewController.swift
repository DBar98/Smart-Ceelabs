//
//  DataDetailViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 05/04/2022.
//

import UIKit

enum TimeFormat: String {
    case hoursMinutes = "dd.MM.yyyy HH:mm:ss"
    case daysMonths = "dd.MM.yyy"
    case months = "MMM yyyy"
}

class DataDetailViewController: UIViewController {

    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    
    var time: Double = 0.0
    var value: String = ""
    var timeFormat: TimeFormat = .hoursMinutes
    var unit: String = ""
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLabels()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    
    private func setupLabels() {
        let date = Date(timeIntervalSince1970: time)
        let formattedDate = date.getFormattedDate(format: timeFormat.rawValue)
        
        valueLabel.text = value
        timeLabel.text = formattedDate
        unitLabel.text = unit
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
