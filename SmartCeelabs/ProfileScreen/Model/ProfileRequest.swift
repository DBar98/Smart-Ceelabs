//
//  ProfileDataRequest.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 21/02/2022.
//

import Foundation

struct ProfileRequest: Codable {
    
    var token: String
    var data: String
    var format: String
    var phase: String
    var cumulative: String
    var from: String
    var to: String
}
