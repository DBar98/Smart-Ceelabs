//
//  RealTimeCollectionCell.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 27/06/2021.
//

import UIKit

class RealTimeCollectionCell: UICollectionViewCell{
    
    @IBOutlet weak var realTimeCellOutlet: UIView!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var upperLabel: UILabel!
    
    
    func setupRealTimeCell(with realTimeCellStruct: RealTimeCellStruct){
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
        
        if (upperLabel != nil && bottomLabel != nil) {
            upperLabel.text = realTimeCellStruct.upperLabel
            bottomLabel.text = realTimeCellStruct.bottomLabel
            realTimeCellOutlet.backgroundColor = realTimeCellStruct.backgroundColor
        }
    }
    
}
