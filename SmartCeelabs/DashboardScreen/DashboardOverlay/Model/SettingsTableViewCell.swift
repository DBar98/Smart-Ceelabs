//
//  SettingsTableViewCell.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 28/01/2022.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var settingsSwitch: UISwitch!
    @IBOutlet weak var cellLabel: UILabel!
    
    var switchStateIsOn: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        settingsSwitch.isOn = switchStateIsOn
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func cellSwitchPressed(_ sender: UISwitch) {
        switchStateIsOn = !switchStateIsOn
        sender.isOn = switchStateIsOn
    }
}
