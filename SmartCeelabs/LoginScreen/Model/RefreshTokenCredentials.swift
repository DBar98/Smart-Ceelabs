//
//  RefreshTokenCredentials.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 16/03/2022.
//

import Foundation

struct RefreshTokenCredentials: Codable {
    var client_id: String = "792689721067-pai18tah0bdo3oarugpst36oul5sv4j4.apps.googleusercontent.com"
    var refresh_token: String
    var grant_type: String = "refresh_token"
}
