//
//  DeviceCollectionCell.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 15/01/2022.
//

import Foundation
import UIKit

class AnalyticsDeviceCell: UICollectionViewCell {
    var token: String = ""
    var macAddress: String = ""
    
    @IBOutlet weak var analyticsContentView: UIView!
    @IBOutlet weak var analyticsImageView: UIImageView!
    @IBOutlet weak var analyticsGroupLabel: UILabel!
    @IBOutlet weak var analyticsLabel: UILabel!
    @IBOutlet weak var analyticsCategoryLabel: UILabel!
}
