//
//  UserProfileTableViewCell.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 04/04/2022.
//

import UIKit

class UserProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var keyName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(keyLabel: String, value: String) {
        keyName.text = keyLabel
        valueLabel.text = value
    }

}
