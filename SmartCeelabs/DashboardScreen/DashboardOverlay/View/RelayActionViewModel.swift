//
//  RelayActionViewModel.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 19/03/2022.
//

import FirebaseFirestore
import GoogleSignIn
import KeychainSwift


protocol RelayActionViewModelInputs {
    func getRelayActions(relayIdx: Int)
    func pushNewRelayAction(relayAction: RelayAction)
    func deleteRelayAction(relayAction: RelayAction)
}

protocol RelayActionViewModelOutputs {
    var onRelayActionsFetch: (([RelayAction]) -> Void )? { get set }
}

protocol RelayActionViewModelType {
    var inputs: RelayActionViewModelInputs { get set }
    var outputs: RelayActionViewModelOutputs { get set }
}

class RelayActionViewModel: RelayActionViewModelType, RelayActionViewModelInputs, RelayActionViewModelOutputs {
    
    var inputs: RelayActionViewModelInputs { get { self } set { } }
    var outputs: RelayActionViewModelOutputs { get { self } set { } }
    var onRelayActionsFetch: (([RelayAction]) -> Void)?
    
    
    var firestore: Firestore
    var defaults: UserDefaults
    var keychain: KeychainSwift
    
    var device: Device
    
    init(device: Device) {
        self.firestore = Firestore.firestore()
        self.defaults = UserDefaults.standard
        self.keychain = KeychainSwift()
        self.device = device
    }
    
    func getRelayActions(relayIdx: Int) {
        if defaults.string(forKey: "auth") == "google" {
//            guard let email = keychain.get("userEmail") else { return }
            
            firestore.collection("relayActions")
//                .whereField("email", isEqualTo: email)
                .whereField("relayIdx", isEqualTo: relayIdx)
                .whereField("mac", isEqualTo: device.mac).addSnapshotListener { [weak self] (querySnapshot, err) in
                    
                    if let err = err
                    {
                        print("Error getting documents: \(err)");
                    }
                    else {
                        guard let documents = querySnapshot?.documents else { return }
                        
                        var relayActions : [RelayAction] = []
                        relayActions = documents.map {
                            
                            RelayAction(id: $0.documentID,
                                        refreshToken: $0.data()["refreshToken"] as? String ?? "",
                                        relayIdx: Int ($0.data()["relayIdx"] as? String ?? "") ?? -1,
                                        relayState: $0.data()["relayState"] as? String ?? "",
                                        timestamp: $0.data()["timestamp"] as? String ?? "")
                        }
                        self?.onRelayActionsFetch?(relayActions)
                    }
                }
        } else {
//            guard let email = keychain.get("userEmail") else { return }

            firestore.collection("relayActions")

                .whereField("relayIdx", isEqualTo: relayIdx)
                .whereField("mac", isEqualTo: device.mac).addSnapshotListener { [weak self] (querySnapshot, err) in
                    
                    if let err = err
                    {
                        print("Error getting documents: \(err)");
                    }
                    else {
                        guard let documents = querySnapshot?.documents else { return }
                        
                        var relayActions : [RelayAction] = []
                        relayActions = documents.map {
                            
                            RelayAction(id: $0.documentID,
                                        relayIdx: Int ($0.data()["relayIdx"] as? String ?? "") ?? -1,
                                        relayState: $0.data()["relayState"] as? String ?? "",
                                        timestamp: $0.data()["timestamp"] as? String ?? "")
                        }
                        self?.onRelayActionsFetch?(relayActions)
                    }
                }
        }
    }
    
    func pushNewRelayAction(relayAction: RelayAction) {
        guard let auth = defaults.string(forKey: "auth") else { return }
        // Add a new document in collection "relayActions"
        firestore.collection("relayActions").document().setData([
            "email": keychain.get("userEmail"),
            "mac": self.device.mac,
            "authType": auth,
            "refreshToken": relayAction.refreshToken,
            "password": relayAction.password ?? "",
            "relayIdx": relayAction.relayIdx,
            "relayState": relayAction.relayState,
            "timestamp": relayAction.timestamp
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    func deleteRelayAction(relayAction: RelayAction) {
        guard let id = relayAction.id else { return }
        firestore.collection("relayActions").document(id).delete() { err in
            if let err = err {
                print(err)
            } else {
                print("Document deleted successfully")
        }
    }
}
}
