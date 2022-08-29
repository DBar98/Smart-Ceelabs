//
//  AnalyticsScreenCell.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 23/01/2022.
//

import Foundation
import UIKit

class AnalyticsScreenCell: UICollectionViewCell{
    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var cellUpperLabel: UILabel!
    @IBOutlet weak var cellBottomLabel: UILabel!
    
    func setupCellDesign(index: Int) {
        self.backgroundColor = UIColor(red: 255, green: 167, blue: 38)
        
        self.contentView.layer.cornerRadius = 2.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        
        if var upperLabel = self.cellUpperLabel, var bottomLabel = self.cellBottomLabel {
            upperLabel.text  = AnalyticsScreenCellEnum.allCases[index].getShortcut
            bottomLabel.text = AnalyticsScreenCellEnum.allCases[index].rawValue
            self.backgroundColor = AnalyticsScreenCellEnum.allCases[index].getBackgroundColor
        }
    }
    
}
