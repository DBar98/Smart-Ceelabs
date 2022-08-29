//
//  RelayRequest.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 04/03/2022.
//

import Foundation

struct RelayRequest: Codable {
    var token: String
    var power: String
    var names: String
}
