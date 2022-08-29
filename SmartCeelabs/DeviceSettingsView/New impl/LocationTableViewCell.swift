//
//  LocationTableViewCell.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 14/04/2022.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

    @IBOutlet weak var address: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
