//
//  Response.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 15/05/2021.

import Foundation

// MARK: - Welcome
struct Response: Codable {
    let status: ResponseStatusCode
    let units: Units
    let data: DataClass
}

// MARK: - DataClass
struct DataClass: Codable {
    let i, q, u, p, s, e_i, e_e: I?

    enum CodingKeys: String, CodingKey {
        case i = "I"
        case q = "Q"
        case u = "U"
        case p = "P"
        case s = "S"
        case e_i = "E_I"
        case e_e = "E_E"
    }
}

// MARK: - I
struct I: Codable {
    let l1, l2, l3, cumulative: [[Double]]?

    enum CodingKeys: String, CodingKey {
        case l1 = "L1"
        case l2 = "L2"
        case l3 = "L3"
        case cumulative = "cumulative"
    }
    
    func getPahse(phase: String) -> [[Double]]? {
        switch phase {
        case "L1":
            return l1 ?? nil
        case "L2":
            return l2 ?? nil
        case "L3":
            return l3 ?? nil
        default:
            return nil
        }
    }
}

enum ResponseStatusCode: String, Codable{
    case ok = "OK"
    case fail = "FAIL"
}

// MARK: - Units
struct Units: Codable {
    let i, q, u, p, s, e_i, e_e: String?

    enum CodingKeys: String, CodingKey {
        case i = "I"
        case q = "Q"
        case u = "U"
        case p = "P"
        case s = "S"
        case e_i = "E_I"
        case e_e = "E_E"
    }
    
    func getUnit(consumptionUnit: String) -> String?{
        switch consumptionUnit {
        case "VOLTAGE":
            return u
        case "CURRENT":
            return i
        case "ACTIVE POWER":
            return p
        case "REACTIVE POWER":
            return q
        case "APPARENT POWER":
            return s
        case "ENERGY IMPORT":
            return e_i
        case "ENERGY EXPORT":
            return e_e
        default:
            return nil
        }
    }
}
