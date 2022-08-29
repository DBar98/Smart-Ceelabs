//
//  WebsocketRequest.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 22/01/2022.
//

import Foundation

struct DisconnectorWSRequest: Codable {
    
    var deviceToken: String
    var data: Bool
    
    var stringRepresentation : String {
            return """
                {
                    "deviceToken":"\(deviceToken)",
                    "data":\(data)
                }
            """
        }
}


