//
//  DeviceOnlineStatusRequest.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 02/04/2022.
//

import Foundation

struct DeviceOnlineStatusRequest {
    var userToken: String
    var state: Bool
    
    var stringRepresentation : String {
            return """
                {
                    "userToken":"\(userToken)",
                    "state":\(state)
                }
            """
        }
}
