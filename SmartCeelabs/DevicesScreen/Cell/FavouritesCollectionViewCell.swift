//
//  FavouritesCollectionViewCell.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 23/03/2022.
//

import UIKit

class FavouritesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!
    
    
    func setupCellUI(device: Device) {
//        print(device)
        cellImage.image = device.type == 1 ? UIImage(named: "electric pump big") : UIImage(named: "toggle-1")
        cellLabel.text = device.name
    }
}
