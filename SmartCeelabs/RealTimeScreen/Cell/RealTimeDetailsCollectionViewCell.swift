//
//  RealTimeDetailsCollectionViewCell.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 11/12/2021.
//

import UIKit

class RealTimeDetailsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var realTimeDetailsCellView: UIView!
    @IBOutlet weak var realTimeDetailsCellLabel: UILabel!
    let inactiveCellColor = UIColor(red: 149, green: 213, blue: 178)
    let selectedCellColor = UIColor(red: 64, green: 145, blue: 108)
    
    weak var parentVC:RealTimeDetailsViewController?
    
    func setupCellUI(index: IndexPath) {
        realTimeDetailsCellLabel.text = "Phase L" + String(index.row + 1)
        realTimeDetailsCellView.backgroundColor = inactiveCellColor
        realTimeDetailsCellLabel.textColor = .white
        realTimeDetailsCellLabel.font = .boldSystemFont(ofSize: realTimeDetailsCellLabel.font.pointSize)
        
        self.roundCorners(.allCorners, radius: 5)
    }
    
    override var isSelected: Bool {
            didSet {
                if !isSelected{
                    //when cell is deselected, then remove phase to display by cell text
                    guard let cellText = self.realTimeDetailsCellLabel.text else {return}
                    parentVC?.phasesToDataDisplayArray = parentVC?.phasesToDataDisplayArray.filter {$0 != cellText.byWords[1]} ?? [""]
                    self.contentView.backgroundColor = inactiveCellColor
                } else {
                    self.contentView.backgroundColor = selectedCellColor
                }
            }
        }
}
