//
//  DeviceDetailChartCell.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 27/01/2022.
//

import UIKit

class DeviceDetailChartCell: UITableViewCell {

    @IBOutlet weak var chartName: UILabel!
    @IBOutlet weak var cellChartView: UIView!
    @IBOutlet weak var cellContentView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
