//
//  RelayActionTableViewCell.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 19/03/2022.
//

import UIKit

class RelayActionTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setupCellUI(relayAction: RelayAction) {
        // timestampt to date time format
        let dateTime = Date(timeIntervalSince1970: Double(relayAction.timestamp) ?? 0)
        self.timeLabel.text = DateFormatter.localizedString(from: dateTime, dateStyle: .long, timeStyle: .short)
        
        // relay state
        self.stateLabel.text = relayAction.relayState
    }

}
