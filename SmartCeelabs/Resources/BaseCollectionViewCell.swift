//
//  BaseCollectionViewCell.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 04/04/2022.
//

import UIKit

enum BaseCellType {
    case timeline
    case disconnectorTimeline
    case analyticsTimeline
    case phase
    case dashboard
}

class BaseCollectionViewCell: UICollectionViewCell {
    
    func setupBackgroundAsSelected(type: BaseCellType) {
        switch type {
        case .timeline:
            self.contentView.backgroundColor = UIColor(red: 189, green: 183, blue: 107)
        case .disconnectorTimeline:
            self.contentView.backgroundColor = UIColor(red: 216, green: 27, blue: 97)
        case .analyticsTimeline:
            self.contentView.backgroundColor = UIColor(red: 189, green: 183, blue: 107)
        case .phase:
            self.contentView.backgroundColor = UIColor(red: 39, green: 134, blue: 39)
        case .dashboard:
            self.contentView.backgroundColor = UIColor(red: 0, green: 182, blue: 255)
        }
    }
    
    func setupBackgroundAsDeselected(type: BaseCellType) {
        switch type {
        case .timeline:
            self.contentView.backgroundColor = UIColor(red: 231, green: 224, blue: 201)
        case .disconnectorTimeline:
            self.contentView.backgroundColor = UIColor(red: 236, green: 96, blue: 113)
        case .analyticsTimeline:
            self.contentView.backgroundColor = UIColor(red: 231, green: 224, blue: 201)
        case .phase:
            self.contentView.backgroundColor = UIColor(red: 193, green: 207, blue: 192)
        case .dashboard:
            self.contentView.backgroundColor = .systemBackground
        }
        
    }
    
}
