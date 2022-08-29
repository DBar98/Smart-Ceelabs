// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(LoginResponse.self, from: jsonData)

import Foundation
import RealmSwift

struct LoginResponse: Codable {
    let status: LoginResponseStatus
    let data: [LoginData]?
    let user: UserStruct?
    let message: String?
    let code: Int?
}

struct LoginData: Codable {
    let owner: Bool
    let mac: String
    let type: Int
    let token: String
    let phaseUse: Int?
    let lora: Bool?
    let nilm: Nilm?

    enum CodingKeys: String, CodingKey {
        case owner, mac, type, token
        case phaseUse = "phase_use"
        case lora
        case nilm = "NILM"
    }
}


struct Nilm: Codable {
    let process, autoLearn: Bool
}

struct UserStruct: Codable {
    let token: String
    let applications: [String]
}

enum LoginResponseStatus: String, Codable {
    case ok = "OK"
    case fail = "FAIL"
}

class Device: Object {
    
    @objc dynamic var owner: Bool = false
    @objc dynamic var mac: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var type: Int = 0
    @objc dynamic var token: String = ""
    @objc dynamic var phaseUse: Int = 0
    @objc dynamic var lora: Bool = false
    @objc dynamic var process: Bool = false
    @objc dynamic var autoLearn: Bool = false
    @objc dynamic var category: String = ""
    @objc dynamic var building: String = ""
    @objc dynamic var favourite: Bool = false
    @objc dynamic var latitude: Double = 48.73040282883915
    @objc dynamic var longitude: Double = 21.2445013990675
}

enum DeviceType: Int {
    case analytics = 1
    case controll = 2
}
