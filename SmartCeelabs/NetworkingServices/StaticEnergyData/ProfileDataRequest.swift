//
//  NetworkingTimeBasedRequest.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 24/01/2022.
//

import Foundation

struct ProfileDataRequest: Codable {
    var token: String
    var data: String
    var format: String
    var phase: String
    var from: String
    var to: String
    var cumulative: String
}
