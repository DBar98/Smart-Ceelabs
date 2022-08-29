//
//  ParametrizedUrl.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 18/02/2022.
//

import Foundation

enum UrlEnum: String {
    
    case profileDataUrl = "https://backend.merito.tech/api2-r/profile"
    case energyDataUrl = "https://backend.merito.tech/api2-r/energy"
    case localAuthUrl = "https://backend.merito.tech/api2-r/auth/local"
    case googleAuthUrl = "https://backend.merito.tech/api2-r/auth/google"
    case googleRefreshToken = "https://www.googleapis.com/oauth2/v4/token"
}
