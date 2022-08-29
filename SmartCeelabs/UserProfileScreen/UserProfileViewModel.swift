//
//  UserProfileViewModel.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 07/03/2022.
//

import UIKit
import KeychainSwift
import GoogleSignIn
import RealmSwift


struct GoogleUser {
    var image: UIImage
    var name: String
}

protocol UserProfileViewModelInputs {
    func retrieveProfileTableViewData()
    func logout()
}

protocol UserProfileViewModelOutputs {
    var name: String? { get set }
    var image: UIImage? { get set }
    var onImageFetch: ((GoogleUser) -> Void)? { get set }
    var onDevicesFetch: ((TableViewInfoModel) -> ())? { get set }
}

protocol UserProfileViewModelType {
    var inputs: UserProfileViewModelInputs { get set }
    var outputs: UserProfileViewModelOutputs { get set }
}

class UserProfileViewModel: UserProfileViewModelInputs, UserProfileViewModelOutputs, UserProfileViewModelType {
    
    var image: UIImage?
    
    var name: String?
    
    var inputs: UserProfileViewModelInputs { get { return self } set { } }
    
    var outputs: UserProfileViewModelOutputs { get { return self } set { } }
    
    var onImageFetch: ((GoogleUser) -> Void)?
    var onDevicesFetch: ((TableViewInfoModel) -> ())?
    
    private let defaults = UserDefaults.standard
    private let keychain = KeychainSwift()

    
    init() {
    }
    
    func viewDidLoad() {
        if let currentUser = GIDSignIn.sharedInstance.currentUser {
            guard let profile = currentUser.profile else { return }
            
            let url = profile.imageURL(withDimension: 300)
            
            if let data = try? Data(contentsOf: url!) {
                name = profile.name
                image = UIImage(data: data)!
            }
        } 
        else {
            if defaults.string(forKey: "auth") == "google" {
                if let imageUrlString = defaults.string(forKey: "googleProfileImage") {
                    let url = URL.init(string: imageUrlString)!
                    
                    if let data = try? Data(contentsOf: url) {
                        image = UIImage(data: data)
                    }
                }
            }
            name = defaults.string(forKey: "userName")
        }
    }
    
    func retrieveProfileTableViewData() {
        guard let realm = try? Realm() else { return }
        let meriTODevices = realm.objects(Device.self)
        print(meriTODevices)
        
        let baseCount: Int = meriTODevices.filter {
            $0.type == 1
        }.count
        
        let controllerCount: Int = meriTODevices.filter {
            $0.type == 2
        }.count
        
        if let email = keychain.get("userEmail") {
            let tableViewModel = TableViewInfoModel(email: email,
                                           deviceCoint: meriTODevices.count,
                                           meriTOBaseCount: baseCount,
                                           meriTOControllerCount: controllerCount,
                                           smartCeelabsWeb: "https://ceelabs.com/")
                        
            onDevicesFetch?(tableViewModel)
        }

    }
    
    func logout() {
        if defaults.string(forKey: "gaveConsent") != nil {
            keychain.delete("userEmail")
            keychain.delete("userPassword")
            keychain.delete("refreshToken")
            defaults.removeObject(forKey: "gaveConsent")
            defaults.set("true", forKey: "useCredentials")
        }
        
        guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        GIDSignIn.sharedInstance.signOut()
        
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginController") as? LoginViewController
        keyWindow.rootViewController = loginVC ?? UIViewController()
        
        UIView.transition(
            with: keyWindow,
            duration: 0.5,
            options: .transitionCrossDissolve,
            animations: {
                keyWindow.makeKeyAndVisible()
            },
            completion: nil
        )
    }
}
