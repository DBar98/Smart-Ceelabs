//
//  CalendarPickerViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 21/02/2022.
//

import UIKit

protocol CalendarPickerViewControllerDelegate: AnyObject {
    func submitButtonPressed(timeFrom: String, timeTo: String)
}

class CalendarPickerViewController: UIViewController {

    @IBOutlet weak var outsideView: UIView!
    @IBOutlet weak var calendarPickerView: UIView!
    @IBOutlet weak var datePickerToDate: UIView!
    @IBOutlet weak var datePickerFromDate: UIView!
    
    weak var delegate: CalendarPickerViewControllerDelegate?
    
    var datePickerFrom = UIDatePicker()
    let datePickerTo = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupDatePickers()
        self.setupUI()
        // Do any additional setup after loading the view.
    }
    
    private func setupDatePickers() {
        self.datePickerFromDate.insertSubview(datePickerFrom, at: 0)
        self.datePickerToDate.addSubview(datePickerTo)
    }
    
    private func setupUI() {
        self.calendarPickerView.layer.cornerRadius = 10
        self.calendarPickerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        self.addGestureRecognizerOutside()
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismissView()
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        delegate?.submitButtonPressed(timeFrom: String(datePickerFrom.date.timeIntervalSince1970), timeTo: String(datePickerTo.date.timeIntervalSince1970))

        self.dismissView()

    }
    
    private func addGestureRecognizerOutside() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTappedOutside))
        outsideView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func didTappedOutside() {
        self.dismissView()
    }
    
    private func dismissView() {
        self.outsideView.backgroundColor = .clear
        self.dismiss(animated: true, completion: nil)
    }
}
