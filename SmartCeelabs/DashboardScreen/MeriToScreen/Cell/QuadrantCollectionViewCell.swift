//
//  QuadrantCollectionViewCell.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 02/02/2022.
//

import UIKit

class QuadrantCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var cellLabel: UILabel!
    
    
    func setupCell() {
        cellContentView.backgroundColor = UIColor(red: 0, green: 188, blue: 212)
        cellContentView.roundCorners(.allCorners, radius: 10)
        cellLabel.textColor = UIColor.white
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.cellContentView.backgroundColor = UIColor(red: 0, green: 129, blue: 196)
            } else {
                cellContentView.backgroundColor = UIColor(red: 0, green: 188, blue: 212)
            }
        }
    }

}
