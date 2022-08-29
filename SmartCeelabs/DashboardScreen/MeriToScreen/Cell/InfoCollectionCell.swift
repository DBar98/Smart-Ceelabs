//
//  InfoCollectionCell.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 22/01/2022.
//

import Foundation
import UIKit

class InfoCollectionCell: UICollectionViewCell {
    @IBOutlet weak var infoCellView: UIView!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var maxValue: UILabel!
    @IBOutlet weak var minValue: UILabel!
    @IBOutlet weak var avgValue: UILabel!
    @IBOutlet weak var dateInfo: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
        
    func updateDisplayedValue(value: String){
        self.valueLabel.text = value
    }
    
    func setCellBackgroundColor(){
        guard let nameLabelText = nameLabel.text else {return}
        let cellName = DashboardRealTimeMenuEnum(rawValue: nameLabelText)

        self.layer.cornerRadius = 5
        switch cellName {
        case .voltage:
            self.backgroundColor = UIColor(red: 38, green: 198, blue: 218)
        case .current:
            self.backgroundColor = UIColor(red: 236, green: 64, blue: 122)
        case .activePower:
            self.backgroundColor = UIColor(red: 102, green: 187, blue: 106)
        case .reactivePower:
            self.backgroundColor = UIColor(red: 255, green: 167, blue: 38)
        case .none:
            self.backgroundColor = UIColor(red: 255, green: 167, blue: 38)
        }
    }
}
