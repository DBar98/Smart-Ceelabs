//
//  UIAlertController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 08/01/2022.
//

import UIKit

extension UIAlertController{
    static func showAlertWithCancelButton(title: String, message: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            alert.self.dismiss(animated: false, completion: nil)
        }))
        
        return alert
    }
    
    static func showAlertWithNumberOfOptions(title: String, message: String, options: [String], choiceButtonHandler: ((String, String) -> ())?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            alert.self.dismiss(animated: true, completion: nil)
        }))
        
        for option in options {
            alert.addAction(UIAlertAction(title: option,
                                          style: .default,
                                          handler: { _ in
    
                choiceButtonHandler?(StaticTimeIntervalEnum(rawValue: option)?.getTimeInterval ?? "", option)
            }))
        
        }
        return alert
    }
}
