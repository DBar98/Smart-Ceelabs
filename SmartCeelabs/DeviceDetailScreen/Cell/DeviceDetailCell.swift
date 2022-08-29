//
//  DeviceDetailCell.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 19/01/2022.
//

import Foundation
import UIKit

class DeviceDetailCell: BaseCollectionViewCell{
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var cellLabel: UILabel!
    
    let lightBlueColor = UIColor(red: 0, green: 182, blue: 212)
    let selectedBlueColor = UIColor(red: 0, green: 182, blue: 255)
    
    func setupCellDesign(with cellText: String){
//        self.layer.borderWidth = 1
//        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.cornerRadius = 5
//        self.backgroundColor = UIColor(red: 0, green: 182, blue: 212)
        self.backgroundColor = .systemBackground
        cellLabel.text = cellText
        cellLabel.textColor = .gray
        
    }
    
    override var isSelected: Bool {
        didSet (oldValue) {
            if isSelected {
                self.backgroundColor = lightBlueColor
                self.cellLabel.textColor = .white
            } else {
                self.backgroundColor = .systemBackground
                self.cellLabel.textColor = .gray
            }
        }
    }
}
