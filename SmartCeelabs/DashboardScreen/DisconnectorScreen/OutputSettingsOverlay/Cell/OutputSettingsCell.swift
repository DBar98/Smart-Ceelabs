//
//  OutputSettingsCell.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 10/04/2022.
//

import UIKit

class OutputSettingsCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var cellTextField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(relayName: String) {
        if cellTextField != nil {
            cellTextField.text = relayName
        }
    }
}
