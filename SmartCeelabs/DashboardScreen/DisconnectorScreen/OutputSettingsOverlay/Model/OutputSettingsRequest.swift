//
//  OutputSettingsRequest.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 10/04/2022.
//

import Foundation

struct OutputSettingsRequest: Codable {
    
    var token: String
    var names: OutputNames
}

struct OutputNames: Codable {
    var R1: String
    var R2: String
    var R3: String
    var R4: String

}
