//
//  ControllDeviceCell.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 15/01/2022.
//

import Foundation
import UIKit

class ControllDeviceCell: UICollectionViewCell {
    var token: String = ""
    var macAddress: String = ""
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var upperLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
}
