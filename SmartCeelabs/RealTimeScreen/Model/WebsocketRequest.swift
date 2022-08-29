//
//  WebsocketRequest.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 22/01/2022.
//

import Foundation

struct WebsocketRequest: Codable {
    
    var deviceToken: String
    var state: Bool
    var data: Bool
    
    var stringRepresentation : String {
            return """
                {
                    "deviceToken":"\(deviceToken)",
                    "state":\(state),
                    "data":\(data)
                }
            """
        }
}


