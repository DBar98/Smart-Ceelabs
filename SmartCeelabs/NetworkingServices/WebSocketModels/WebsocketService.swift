//
//  WebsocketService.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 03/12/2021.
//

import Foundation


class WebSocketService: NSObject, URLSessionWebSocketDelegate {
    
    var webSocketRequest: String = ""
    var wantSingleValueFromRequest: Bool = false
    var wantsOnlineStatus: Bool = false
    var websocketTask: URLSessionWebSocketTask?
    
    var onlineStatusMessages: [DeviceOnlineStatusResponse] = []
    var onlineStatusDataReady: (([DeviceOnlineStatusResponse]) -> ())?
    var deviceCount: Int?
    
    private override init() {
    }
    
    static let shared = WebSocketService()
    
    func startFetchData(webSocketRequest: String, wantSingleValueFromRequest: Bool, wantsOnlineStatus: Bool) {
        self.webSocketRequest = webSocketRequest
        self.wantSingleValueFromRequest = wantSingleValueFromRequest
        self.wantsOnlineStatus = wantsOnlineStatus
        
        let webSocketSession = URLSession(configuration: .default,
                                          delegate: self,
                                          delegateQueue: OperationQueue()
        )
        
        let websocketUrl = URL(string: "wss://backend.merito.tech/api2-ws")
        websocketTask = webSocketSession.webSocketTask(with: websocketUrl!)
        websocketTask?.resume()
    }
    
    func ping(){
        websocketTask?.sendPing{error in
            if let error = error{
                print("Ping error:  \(error) ")
            }
        }
    }
    
    func close(){
        websocketTask?.cancel(with: .goingAway, reason: "Demo ended".data(using: .utf8))
        webSocketResponsesArray.removeAll()
    }
    
    func doSend(){
        websocketTask?.send(.string(webSocketRequest), completionHandler: {error in
            if let error = error {
                print("🚫 Error: \(error) while sending doing doSend() 🚫" )
            }
        })
    }
    
    func receive(){
        websocketTask?.receive(completionHandler: { [weak self] result in
            guard let self = self else {return}
            
            switch result{
            case .success(let message):
                switch message{
                case .data(let webSocketData):
                    print("Data: \(webSocketData)")
                case .string(let message):
                    //Decode the message to WebSocketResponse type
                    let decoder = JSONDecoder()
                    do {
                        if !self.wantsOnlineStatus {
                            let message = try decoder.decode(WebSocketResponse.self, from: Data(message.utf8))
                            if !self.wantSingleValueFromRequest {
                                webSocketResponsesArray.append(message)
                            } else {
                                webSocketResponsesArray = []
                                webSocketResponsesArray.append(message)
                            }
                        } else {
                            let message = try decoder.decode(DeviceOnlineStatusResponse.self, from: Data(message.utf8))
                            self.onlineStatusMessages.append(message)
                            if let deviceCount = self.deviceCount {
                                if self.onlineStatusMessages.count == deviceCount {
                                    print(self.onlineStatusMessages)
                                    self.onlineStatusDataReady?(self.onlineStatusMessages)
                                }
                            }
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                @unknown default:
                    break
                }
            case .failure(let error):
                self.close()
                print("🚫 Receive the error \(error) 🚫")
                return
            }
            self.receive()
        })
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Websocket connection was opened.")
        ping()
        doSend()
        receive()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Did close connection with reason.")
    }
}
