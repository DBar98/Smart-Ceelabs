//
//  TimelineRequest.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 05/03/2022.
//

import Foundation

struct TimelineRequest: Codable {
    var token: String
    var from: String
    var to: String
    var milliseconds: Bool = true
}
