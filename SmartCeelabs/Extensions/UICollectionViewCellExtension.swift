//
//  UICollectionViewCellUtils.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 03/11/2021.
//

import Foundation
import UIKit

extension UICollectionViewCell{
    func setupCellView(with uiView: UIView, uiColor: UIColor) {
        uiView.backgroundColor = uiColor
        
//        uiView.superview?.layer.cornerRadius = 8
    }
    @objc 
    func setupCellLabel(with uiLabel: UILabel) {
        uiLabel.textColor = .white
        uiLabel.font = .boldSystemFont(ofSize: uiLabel.font.pointSize)
    }
}
