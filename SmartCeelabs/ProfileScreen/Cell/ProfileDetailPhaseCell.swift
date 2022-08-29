//
//  ProfileDetailPhaseCell.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 02/11/2021.
//

import UIKit

class ProfileDetailPhaseCell: BaseCollectionViewCell {
    
    @IBOutlet weak var profilePhaseView: UIView!
    @IBOutlet weak var profilePhaseLabel: UILabel!
    
    weak var parentVC:ProfileDetailViewController?
    
    func setupCellUI(cellText: String) {
        profilePhaseView.backgroundColor = UIColor(red: 193, green: 207, blue: 192)
        profilePhaseLabel.text = cellText
        profilePhaseLabel.textColor = .white
        profilePhaseLabel.font = .boldSystemFont(ofSize: profilePhaseLabel.font.pointSize)
        
        self.roundCorners(.allCorners, radius: 5)
    }
    
    override var isSelected: Bool {
            didSet {
                if !isSelected{
                    self.profilePhaseView.backgroundColor = UIColor(red: 193, green: 207, blue: 192)
                    guard let cellText = self.profilePhaseLabel.text, let parentVC = parentVC else {return}
                    parentVC.phaseNumberForFetching =  parentVC.phaseNumberForFetching.filter {$0 != String(cellText.byWords.last ?? "")}
                } else {
                    self.profilePhaseView.backgroundColor = UIColor(red: 39, green: 134, blue: 39)
                }
            }
        }

}
