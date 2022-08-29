//
//  DeviceOnlineStatusResponse.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 02/04/2022.
//

import Foundation

struct DeviceOnlineStatusResponse: Codable {
    let topic, device: String
    let data: OnlineData
}

struct OnlineData: Codable {
    let status: StatusEnum
    let fw: String
}

enum StatusEnum: String, Codable {
    case online = "ONLINE"
    case offline = "OFFLINE"
}

var onlineStatusMessages: [DeviceOnlineStatusResponse] = []
