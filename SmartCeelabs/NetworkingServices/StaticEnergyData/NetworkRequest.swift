//
//  NetworkRequest.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 15/04/2021.
//

import Foundation
import Alamofire

struct NetworkRequest: Encodable {
    var token: String
    var data: String
    var format: String
    var phase: String
    var cumulative: String
    var from: String
    var to: String
    
    
    
    init(token: String, data: String, format:String, phase: String, cumulative: String, from: String, to: String) {
        self.token = token
        self.data = data
        self.format = format
        self.phase = phase
        self.cumulative = cumulative
        self.from = from
        self.to = to
    }
    
    
    func getDataFromUrl(completion: @escaping (Response?) ->()){
        var consumptionData : Response?
        
        AF.request("https://backend.merito.tech/api2-r/profile", method: .post, parameters: NetworkRequest(token: self.token, data: self.data, format: self.format, phase: "L1,L2,L3", cumulative: "true", from: self.from, to: self.to))
            .responseDecodable(of: Response.self) { response in
                switch response.result {
                case .success:
                    do {
                        consumptionData = try response.result.get()
                        completion(consumptionData)
                    }
                    catch {print(error)}
                    
                case .failure(let error):
                    print (error)
                    completion(nil)
                }
            }
    }
}





