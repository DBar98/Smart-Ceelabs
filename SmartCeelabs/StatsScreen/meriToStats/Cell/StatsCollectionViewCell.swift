//
//  StatsCollectionViewCell.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 19/02/2022.
//

import UIKit

class StatsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var cellLabel: UILabel!
    
    func setupCellUI(statsEnergyElement: StatsColectionElementEnum) {
        if let cellLabel = cellLabel {
            
            self.layer.cornerRadius = 5.0
            cellLabel.textColor = .white
            
            switch statsEnergyElement {
            case .profile:
                self.backgroundColor = UIColor(red: 38, green: 198, blue: 218)
            case .realTime:
                self.backgroundColor = UIColor(red: 236, green: 64, blue: 122)
            case .analytics:
                self.backgroundColor = UIColor(red: 255, green: 167, blue: 38)
            }
        }
    }
}
