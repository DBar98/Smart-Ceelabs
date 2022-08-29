//
//  AnalyticsTableViewCell.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 26/02/2022.
//

import UIKit

class AnalyticsTableViewCell: UITableViewCell {

    @IBOutlet weak var upperLabel: UILabel!
    @IBOutlet weak var cellImage: UIView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var flashImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCellUI(cellText: String) {
        let cellText = EnergyDataOutputsEnum(rawValue: cellText)
        var color: UIColor = .purple
        switch cellText {
        case .energyImport:
            color = UIColor(red: 43, green: 134, blue: 33)
        case .energyExport:
            color = UIColor(red: 9, green: 66, blue: 56)
        case .Q1:
            color = UIColor(red: 11, green: 134, blue: 211)
        case .Q2:
            color = UIColor(red: 111, green: 134, blue: 155)
        case .Q3:
            color = UIColor(red: 123, green: 2, blue: 4)
        case .Q4:
            color = UIColor(red: 220, green: 134, blue: 9)
        case .none:
            color = UIColor(red: 77, green: 134, blue: 33)
        }
        flashImage.image = UIImage(systemName: "bolt.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(color)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    
}
