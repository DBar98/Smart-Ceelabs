//
//  DisconnectorStateRequest.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 05/03/2022.
//

import Foundation

struct DisconnectorStateRequest: Codable {
    
    var token: String
    var relay_1: Bool
    var relay_2: Bool
    var relay_3: Bool
    var relay_4: Bool
}
