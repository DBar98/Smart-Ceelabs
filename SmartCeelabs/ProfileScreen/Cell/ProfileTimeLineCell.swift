//
//  ProfileTimeLineCell.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 30/10/2021.
//

import Foundation
import UIKit

class ProfileTimeLineCell : BaseCollectionViewCell{
    
    @IBOutlet weak var timeLineCellLabel: UILabel!
    @IBOutlet weak var timeLineCellView: UIView!
    
    func setupCellUI(cellText: String) {
        timeLineCellLabel.text = cellText
        timeLineCellLabel.textColor = .white
        timeLineCellLabel.font = .boldSystemFont(ofSize: timeLineCellLabel.font.pointSize)
        timeLineCellView.backgroundColor = UIColor(red: 231, green: 224, blue: 201)

        self.roundCorners(.allCorners, radius: 5)
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.contentView.backgroundColor = UIColor(red: 189, green: 183, blue: 107)
            } else {
                self.timeLineCellView.backgroundColor = UIColor(red: 231, green: 224, blue: 201)
            }
        }
    }
}
