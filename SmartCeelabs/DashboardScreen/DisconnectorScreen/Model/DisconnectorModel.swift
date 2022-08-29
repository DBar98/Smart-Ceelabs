//
//  DisconnectorModel.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 04/03/2022.
//

import Foundation

class DisconnectorModel {
    
    internal init(relay1: RelayModel, relay2: RelayModel, relay3: RelayModel, relay4: RelayModel) {
        self.relay1 = relay1
        self.relay2 = relay2
        self.relay3 = relay3
        self.relay4 = relay4
    }
    
    
    var relay1: RelayModel
    var relay2: RelayModel
    var relay3: RelayModel
    var relay4: RelayModel
    
    
    func getRelayByIndexNumber(index: Int) -> RelayModel {
        switch index {
        case 0 :
            return relay1
        case 1 :
            return relay2
        case 2 :
            return relay3
        case 3 :
            return relay4
        default :
            return relay1
        }
    }
}

class RelayModel {
    internal init(name: String, energy: Double, state: Bool) {
        self.name = name
        self.energy = energy
        self.state = state
    }
    
    var name: String
    var energy: Double
    var state: Bool
}
