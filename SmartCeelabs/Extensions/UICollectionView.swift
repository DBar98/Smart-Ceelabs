//
//  UICollectionView.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 10/02/2022.
//

import Foundation
import UIKit

extension UICollectionView {
    
    func setCollectionHotizontalFlowLayoutWithSpacing(){
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 20
        layout.scrollDirection = .horizontal
        
        self.collectionViewLayout = layout
    }
}

extension UICollectionView {

    func deselectAllItems(animated: Bool) {
        guard let selectedItems = indexPathsForSelectedItems else { return }
        for indexPath in selectedItems { deselectItem(at: indexPath, animated: animated) }
    }
}
