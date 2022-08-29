//
//  AnalyticsTimelineCell.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 28/02/2022.
//

import UIKit

class AnalyticsTimelineCell: BaseCollectionViewCell {
    
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellContentView: UIView!
    
    func setupCellUI(cellText: String) {
        cellLabel.text = cellText
        cellLabel.textColor = .white
        cellLabel.font = .boldSystemFont(ofSize: cellLabel.font.pointSize)
        cellContentView.backgroundColor = UIColor(red: 231, green: 224, blue: 201)
        cellContentView.layer.cornerRadius = 10
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.contentView.backgroundColor = UIColor(red: 189, green: 183, blue: 107)
            } else {
                self.cellContentView.backgroundColor = UIColor(red: 231, green: 224, blue: 201)
            }
        }
    }
}
