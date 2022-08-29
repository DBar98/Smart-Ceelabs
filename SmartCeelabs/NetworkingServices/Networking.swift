//
//  Networking.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 06/01/2022.
//

import Foundation
import Alamofire

class Networking{
    
    func post<T: Codable, A: Codable>(url: String, jsonBody: A, onCompletion: @escaping (T) -> Void, onError: ((Error) -> ())? = nil) {
        
        guard let url = URL(string: url) else {return}
        
        AF.request(url, method: .post, parameters: jsonBody, encoder: JSONParameterEncoder.default).responseJSON { response in
            guard response.error == nil else {
                onError?(response.error!)
                return
            }
            
            if let responseData = response.data{
                do {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(T.self, from: responseData)
                    onCompletion(decodedData)
                } catch (let error){
                    print(error)
                    onError?(error)
                }
            }
        }
    }
}
