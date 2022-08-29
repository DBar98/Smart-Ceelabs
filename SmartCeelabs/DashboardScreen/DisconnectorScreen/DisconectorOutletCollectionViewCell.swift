//
//  DisconectorOutletCollectionViewCell.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 03/03/2022.
//

import UIKit

class DisconectorOutletCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var outletName: UILabel!
    @IBOutlet weak var relaySwitch: UISwitch!
    @IBOutlet weak var energyValue: UILabel!
    
    var viewModel: DisconnectorViewModelType?
    var disconnector: DisconnectorModel?
    
    var index: Int = 0
    
    func setupCellUI() {
        cellContentView.backgroundColor = UIColor(red: 38, green: 198, blue: 218)
        energyValue.textColor = .white
        outletName.textColor = .white
        self.layer.cornerRadius = 5
    }
    
    func setupUI(index: Int, disconnector: DisconnectorModel) {
        self.index = index
        self.disconnector = disconnector
    }
    
    @IBAction func relaySwitchPressed(_ sender: UISwitch) {
        var switchState: Bool = relaySwitch.isOn
        
        guard let disconnector = disconnector else {
            return
        }
        
        var disc: DisconnectorModel = disconnector
        disc.getRelayByIndexNumber(index: index).state = switchState
        
        viewModel?.inputs.changeRelayState(disconnector: disc)
        viewModel?.inputs.stopDataFetch()
        viewModel?.inputs.fetchDataFromWebSocket()
    }
}
