//// This file was generated from JSON Schema using quicktype, do not modify it directly.
//// To parse the JSON, add this file to your project and do:
////
////   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)
//
//import Foundation
//
//// MARK: - Welcome
//struct EnergyDataResponse: Codable {
//    let status: EnergyDataStatus
//    let units: EnergyDataUnits
//    let data: EnergyResponseData
//}
//
//// MARK: - DataClass
//struct EnergyResponseData: Codable {
//    let eI, eE, q1, q2, q3, q4: EnergyDataOutput?
//
//    enum EnergyResponseDataKeys: String, CodingKey {
//        case eI = "E_I"
//        case eE = "E_E"
//        case q1 = "Q1"
//        case q2 = "Q2"
//        case q3 = "Q3"
//        case q4 = "Q4"
//
//    }
////    let eI, eE, q1, q2, q3, q4: EnergyDataOutput?
//////    let q1, q2, q3, q4: EnergyDataOutput?
////
////    enum EnergyResponseDataKeys: String, CodingKey {
////        case eI = "E_I"
////        case eE = "E_E"
////        case q1 = "Q1"
////        case q2 = "Q2"
////        case q3 = "Q3"
////        case q4 = "Q4"
////    }
//
////    func getDataByOutput(output: EnergyResponseDataKeys) -> [[Double]]{
////
////        switch output {
////        case .eI:
////            return eI?.cum ?? []
////        case .eE:
////            return eE?.cum ?? []
////        case .q1:
////            return q1?.cum ?? []
////        case .q2:
////            return q2?.cum ?? []
////        case .q3:
////            return q3?.cum ?? []
////        case .q4:
////            return q4?.cum ?? []
////        }
////    }
//}
//
//struct EnergyDataOutput: Codable {
//    let cum: [[Double]]
//    enum CodingKeys: String, CodingKey {
//        case cum = "CUM"
//    }
//}
//
//// MARK: - Units
//struct EnergyDataUnits: Codable {
//    let eI, eE: String?
//    let q1, q2, q3, q4: String?
//
//    enum EnergyResponseDataKeys: String, CodingKey {
//        case eI = "E_I"
//        case eE = "E_E"
//        case q1 = "Q1"
//        case q2 = "Q2"
//        case q3 = "Q3"
//        case q4 = "Q4"
//    }}
//
enum EnergyDataStatus: String, Codable {
    case ok = "OK"
    case fail = "FAIL"
}





// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)


// MARK: - Welcome
struct EnergyDataResponse: Codable {
    let status: EnergyDataStatus
    let units: Unitss
    let data: EnergyData
}

// MARK: - DataClass
struct EnergyData: Codable {
    let eI, eE, q1, q2, q3, q4: EnergyDataOutput?

    enum CodingKeys: String, CodingKey {
        case eI = "E_I"
        case eE = "E_E"
        case q1 = "Q1"
        case q2 = "Q2"
        case q3 = "Q3"
        case q4 = "Q4"
    }
    
    func getDataByOutput(output: String) -> EnergyDataOutput?{
            switch output {
            case "E_I":
                return eI
            case "E_E":
                return eE
            case "Q1":
                return q1
            case "Q2":
                return q2
            case "Q3":
                return q3
            case "Q4":
                return q4
            default:
                return nil
            }
        }
}

struct EnergyDataOutput: Codable {
    let cum: [[Double]]
    
    enum CodingKeys: String, CodingKey {
        case cum = "CUM"
    }
}
// MARK: - Units
struct Unitss: Codable {
    let eI, eE, q1, q2, q3, q4: String?

    enum CodingKeys: String, CodingKey {
        case eI = "E_I"
        case eE = "E_E"
        case q1 = "Q1"
        case q2 = "Q2"
        case q3 = "Q3"
        case q4 = "Q4"
    }
    
    func getDataByOutput(output: String) -> String?{
            switch output {
            case "E_I":
                return eI
            case "E_E":
                return eE
            case "Q1":
                return q1
            case "Q2":
                return q2
            case "Q3":
                return q3
            case "Q4":
                return q4
            default:
                return nil
            }
        }
}
