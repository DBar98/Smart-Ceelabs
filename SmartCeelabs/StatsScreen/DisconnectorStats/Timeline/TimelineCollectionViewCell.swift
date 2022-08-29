//
//  TimelineCollectionViewCell.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 06/03/2022.
//

import UIKit

class TimelineCollectionViewCell: BaseCollectionViewCell {
    
    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var timeIntervalLabel: UILabel!
    
    func setupCellUI(cellText: String) {
        timeIntervalLabel.text = cellText
        timeIntervalLabel.textColor = .white
        timeIntervalLabel.font = .boldSystemFont(ofSize: timeIntervalLabel.font.pointSize)
        cellContentView.backgroundColor = UIColor(red: 236, green: 96, blue: 113)
        cellContentView.layer.cornerRadius = 10
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.contentView.backgroundColor = UIColor(red: 216, green: 27, blue: 97)
            } else {
                self.cellContentView.backgroundColor = UIColor(red: 236, green: 96, blue: 113)
            }
        }
    }
}
