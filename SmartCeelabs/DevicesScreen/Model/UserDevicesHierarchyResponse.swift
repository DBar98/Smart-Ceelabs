//
//  UserDevicesHierarchyResponse.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 04/02/2022.
//

import Foundation

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct UserDevicesHierarchyResponse: Codable {
    let status: Status
    let data: HierarchyData
}

enum Status: String, Codable {
    case ok = "OK"
    case fail = "FAIL"
}

// MARK: - WelcomeData
struct HierarchyData: Codable {
    let nodes: [Node]
    let tags: [TagClass]
}

// MARK: - Node
struct Node: Codable {
    let title: String?
    let isExpanded: Bool?
    let children: [NodeChild]?
    let data: ChildData?
//    let data: NodeData
//    let isSelected: Bool
}

// MARK: - NodeChild
struct NodeChild: Codable {
    let title: String?
    let isExpanded: Bool?
    let isLeaf: Bool?
    let children: [NodeChild]?
    let data: ChildData?
//    let isSelected: Bool
//    let isLeaf: Bool?
}

// MARK: - ChildData
struct ChildData: Codable {
    let mac: String?
    let id: Int?
//    let isEdited, showButton: Bool
//    let reportVisible: Bool?
    let type: Int?

    enum CodingKeys: String, CodingKey {
        case mac, id
//        case reportVisible = "report_visible"
//        case reportMode = "report_mode"
        case type
    }
}

// MARK: - NodeData
struct NodeData: Codable {
    let id: Int
    let showButton, isEdited: Bool
}

// MARK: - TagClass
struct TagClass: Codable {
    let id: Int
    let title, mac: String?
    let tags: [String]
    let lat, lng: String?
}

//enum TagEnum: String, Codable {
//    case disconnector = "Disconnector"
//    case meriTo = "MeriTo"
//    case ttttt = "Ttttt"
//}
