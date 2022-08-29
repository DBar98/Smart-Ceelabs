//
//  SearchTableViewCell.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 21/03/2022.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var deviceName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCellUI(device: Device) {
//        guard var nameLabel = self.deviceName.text else { return }
        deviceName.text = device.name
    }

}
