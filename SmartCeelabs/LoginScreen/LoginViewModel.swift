//  LoginViewModel.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 04/01/2022.
//
import UIKit
import GoogleSignIn
import RealmSwift
import LocalAuthentication
import BiometricAuthentication
import KeychainSwift
import SwiftUI

enum LoginType {
    case google
    case local
}

protocol LoginViewModelInputs {
    func viewDidLoad(controller: LoginViewController)
}

protocol LoginViewModelOutputs {
    var onRefreshToken: ((String) -> Void)? { get set }
}


protocol BiometricsSupportType {
    func startBiometricAuth(controller: LoginViewController, onCompletion: @escaping () -> Void)
    func segueToTabBarWhenSuccessfulLogIn(controller: UIViewController)
}

extension BiometricsSupportType {
    
    func startBiometricAuth(controller: LoginViewController, onCompletion: @escaping () -> Void){
    BioMetricAuthenticator.authenticateWithBioMetrics(reason: "Authenticate for logging in") { result in
        switch result {
        case .success:
            onCompletion()
        case .failure(let error):
            switch error {
            //when user doesnt want to use biometrics
            case .biometryNotAvailable:
                segueToTabBarWhenSuccessfulLogIn(controller: controller)
            //when biometrics try fails
            default:
                let fallbackVC = LoginFallbackViewController.instantiate()
                guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
                keyWindow.rootViewController = fallbackVC
                
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
    }
}
    
    func segueToTabBarWhenSuccessfulLogIn(controller: UIViewController){
        // go to main menu
        let tabViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TapBarController") as! TapBarViewController
        controller.view.window?.rootViewController = tabViewController
        controller.view.window?.makeKeyAndVisible()
    }
}

class LoginViewModel: LoginViewModelInputs, LoginViewModelOutputs, BiometricsSupportType{
   
    var onRefreshToken: ((String) -> Void)?
    private let networkingService: Networking
    private var currentController: UIViewController?
    private let defaults = UserDefaults.standard
    private let keychain = KeychainSwift()
    
    init() {
        self.networkingService = Networking()
    }
    
    func viewDidLoad(controller: LoginViewController) {
        
        if defaults.string(forKey: "gaveConsent") != nil, defaults.string(forKey: "useCredentials") == nil {
            startBiometricAuth(controller: controller, onCompletion: {
                
                guard let auth = self.defaults.string(forKey: "auth") else { return }
                // check if last biometrics was used by uer credentials or google access token
                
                if auth == "local" { // biometrics using user credentials
                    let email = self.keychain.get("userEmail")
                    let password = self.keychain.get("userPassword")
                    
                    guard let email = email, let password = password else {
                        return
                    }
                    self.localAuthLogin(userEmail: email, hashedPassword: password, url: UrlEnum.localAuthUrl.rawValue, controller: controller, consentWasGiven: true)
                }
                else {
                    let refreshToken = self.keychain.get("refreshToken")
                    guard let token = refreshToken else { return }
                    print(token)
                    self.refreshAccessToken(refreshToken: token)
                    self.onRefreshToken = { accessToken in
                        self.logUserInByGoogle(consentWasGiven: true, controller: controller, accessToken: accessToken)
                    }
                }
            })
        }
    }
    
    func logUserIn(userEmail: String, password: String, url: String, controller: LoginViewController, loginType: LoginType, isRefreshing: Bool) {
        
        switch loginType {
        case .google:
            logUserInByGoogle(consentWasGiven: false, controller: controller, accessToken: nil)
        case .local:
            let hashedPassword = isRefreshing ? password : password.toSHA256()
            self.localAuthLogin(userEmail: userEmail, hashedPassword: hashedPassword, url: UrlEnum.localAuthUrl.rawValue, controller: controller, consentWasGiven: false)
        }
    }
    
    func logUserInByGoogle(consentWasGiven: Bool, controller: LoginViewController, accessToken: String?){
        
        if !consentWasGiven {
            
            let signInConfig = GoogleSignIn.GIDConfiguration.init(clientID: "792689721067-pai18tah0bdo3oarugpst36oul5sv4j4.apps.googleusercontent.com")
            
            currentController = instantiateTopMostViewController()
            
            GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: currentController ?? self.instantiateViewController(controllerIdentifier: "LoginController")) {[weak self] (user, error) in
                
                guard let self = self else {return}
                guard error == nil else {return}
                /**
                 In case of successful Google Authentication
                 */
                if let currentUser = GIDSignIn.sharedInstance.currentUser {
                                        
                    self.networkingService.post(url: UrlEnum.googleAuthUrl.rawValue, jsonBody: GoogleLoginCredentials(token: currentUser.authentication.accessToken), onCompletion: { [weak self] (response: LoginResponse) in
                        
                        guard let self = self else { return }
                        guard let data = response.data else {return}
                        
                        switch response.status {
                        case .ok:
                            //save user devices - new way by update
                            self.updateUserDevices(devices: data)
                        
                            if let userToken = response.user?.token{
                                self.defaults.setValue(userToken, forKey: "userToken")
                            }
                            //save current user email
                            guard let email = currentUser.profile?.email else { return }
                            self.keychain.set(email, forKey: "userEmail")
                            // save current user
                            guard let profile = currentUser.profile else { return }
                            let refreshToken = currentUser.authentication.refreshToken
                            let googleName = profile.name
                            let googleProfileImageUrl = profile.imageURL(withDimension: 300)
                            print(refreshToken)
                            self.saveGoogleUserData(name: googleName, imageUrl: googleProfileImageUrl, refreshToken: refreshToken)

                            self.defaults.removeObject(forKey: "useCredentials")
                                                    
                            self.startBiometricAuth(controller: controller, onCompletion: {
                                self.defaults.set("true", forKey: "gaveConsent")
                                self.defaults.set("google", forKey: "auth")
                                self.segueToTabBarWhenSuccessfulLogIn()
                            })

                        case .fail:
                            let alert = UIAlertController.showAlertWithCancelButton(title: "Google Login Error", message: response.message ?? "Something went wrong!")
                            self.currentController?.present(alert, animated: true, completion: nil)
                        }
                    }, onError: { error in
                        print("\(error)")
                    })
                }
            }
        } else {
            
            guard let accessToken = accessToken else {
                return
            }
            print(accessToken)
            self.networkingService.post(url: UrlEnum.googleAuthUrl.rawValue, jsonBody: GoogleLoginCredentials(token: accessToken), onCompletion: { (response: LoginResponse) in
                
                guard let data = response.data else {return}
                
                switch response.status {
                case .ok:
                    //save user devices - new way by update
                    self.updateUserDevices(devices: data)
                    
                    if let userToken = response.user?.token{
                        self.defaults.setValue(userToken, forKey: "userToken")
                    }
                    
                    self.defaults.removeObject(forKey: "useCredentials")
                    self.segueToTabBarWhenSuccessfulLogIn(controller: controller)
                case .fail:
                    let alert = UIAlertController.showAlertWithCancelButton(title: "Google Login Error", message: response.message ?? "Something went wrong!")
                    self.currentController?.present(alert, animated: true, completion: nil)
                }
            }, onError: { error in
                print(error)
            })
        }
        
    }
    
    private func localAuthLogin(userEmail: String, hashedPassword: String, url: String, controller: LoginViewController, consentWasGiven: Bool) {
        
        
        let credentials = LocalLoginCredentials(login: userEmail,
                                                password: hashedPassword)
        networkingService.post(url: url,
                               jsonBody: credentials,
                               onCompletion: { [weak self] (response: LoginResponse) in
            guard let self = self else { return }
            self.currentController = self.instantiateTopMostViewController()

            switch response.status {
            case .ok:
                // save user email and pass to keychain
                self.keychain.set(userEmail, forKey:"userEmail")
                self.keychain.set(hashedPassword, forKey:"userPassword")
                
                guard let data = response.data else {return}
                
                //save user devices - new way by update
                self.updateUserDevices(devices: data)
                //old way by delete and add
                //self.saveAllUserDevices(devices: data)
                
                //save user token
                if let userToken = response.user?.token{
                    let delimiter = "|"
                    let name = userToken.components(separatedBy: delimiter)
                    self.defaults.set(name[0], forKey: "userName")
                    self.defaults.setValue(userToken, forKey: "userToken")
                    self.defaults.removeObject(forKey: "useCredentials")
                }
                if consentWasGiven {
                    self.segueToTabBarWhenSuccessfulLogIn()
                } else {
                    self.startBiometricAuth(controller: controller, onCompletion: {
                        self.defaults.set("true", forKey: "gaveConsent")
                        self.segueToTabBarWhenSuccessfulLogIn()
                    })
                }
                self.defaults.set("local", forKey: "auth")
            case .fail:
                let alert = UIAlertController.showAlertWithCancelButton(title: "Login Error", message: response.message ?? "Something went wrong!")
                self.currentController?.present(alert, animated: true, completion: nil)
            }
        }, onError: { error in
            print("🚫 Error occured: \(error)🚫")
        })
    }
    
    private func saveGoogleUserData(name: String, imageUrl: URL?, refreshToken: String) {
        self.defaults.set(name, forKey: "userName")
        self.keychain.set(refreshToken, forKey: "refreshToken")
        if let imageUrl = imageUrl {
            self.defaults.set(imageUrl.absoluteString, forKey: "googleProfileImage")
        }
    }
    
    func refreshAccessToken(refreshToken: String) {
        let request = RefreshTokenCredentials(refresh_token: refreshToken)
        
        networkingService.post(url: UrlEnum.googleRefreshToken.rawValue,
                               jsonBody: request,
                               onCompletion: { [weak self] (response: RefreshTokenResponse) in
            self?.onRefreshToken?(response.accessToken)
        })
    }
    
    func instantiateTopMostViewController() -> UIViewController? {
        var topMostViewController = UIApplication.shared.keyWindow?.rootViewController
            while let presentedViewController = topMostViewController?.presentedViewController {
                topMostViewController = presentedViewController
            }
        return topMostViewController
    }
    
    func instantiateViewController(controllerIdentifier: String) -> UIViewController{
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: controllerIdentifier)
        
        return vc
    }
    
    func segueToTabBarWhenSuccessfulLogIn(){
        let tabViewController = self.instantiateViewController(controllerIdentifier: "TapBarController")
        self.currentController?.view.window?.rootViewController = tabViewController
        self.currentController?.view.window?.makeKeyAndVisible()
    }
    
    func updateAllUserDevices(){
//        var devices = self.realm.objects(Device.self).map{$0.}
    }
    
    func saveAllUserDevices(devices: [LoginData]) {
        guard let realm = try? Realm() else { return }
        try? realm.write{
            realm.deleteAll()
        }
        
        realm.beginWrite()
        
        for device in devices {
            let deviceToAdd = Device()
            deviceToAdd.token = device.token
            deviceToAdd.name = device.mac
            deviceToAdd.mac = device.mac
            deviceToAdd.autoLearn = ((device.nilm?.autoLearn) != nil)
            deviceToAdd.owner = device.owner
            deviceToAdd.lora = device.lora ?? false
            deviceToAdd.phaseUse = device.phaseUse ?? 0
            deviceToAdd.process = ((device.nilm?.process) != nil)
            deviceToAdd.type = device.type
            
            realm.add(deviceToAdd)
        }
        try? realm.commitWrite()
    }
    
    func updateUserDevices(devices: [LoginData]) {
        guard let realm = try? Realm() else { return }
        
        let realmDevices = realm.objects(Device.self)
        let realmDevicesMac: [String] = realmDevices.map { $0.mac }
        let fetchedDevicesMac: [String] = devices.map { $0.mac }
        
        //Remove devices that are in Realm but not fetched anymore
        realmDevicesMac.map {
            let realmMac  = $0
            
            if !fetchedDevicesMac.contains(realmMac) {
                let realmDeviceToDelete = realm.objects(Device.self).filter {
                    $0.mac == realmMac
                }.first
                
                if let realmDeviceToDelete = realmDeviceToDelete {
                    try? realm.write {
                        realm.delete(realmDeviceToDelete)
                    }
                }
            }
        }

         fetchedDevicesMac.map {
            let fetchedMac = $0
            if !realmDevicesMac.contains(fetchedMac) {
                //find missing device in newly fetched devices
                let newDevice = devices.filter {
                    $0.mac == fetchedMac
                }.first
                
                guard let newDevice = newDevice else { return }
                
                //add newly fetched device
                realm.beginWrite()

                let deviceToAdd = Device()
                deviceToAdd.token = newDevice.token
                deviceToAdd.name = newDevice.mac
                deviceToAdd.mac = newDevice.mac
                deviceToAdd.autoLearn = ((newDevice.nilm?.autoLearn) != nil)
                deviceToAdd.owner = newDevice.owner
                deviceToAdd.lora = newDevice.lora ?? false
                deviceToAdd.phaseUse = newDevice.phaseUse ?? 0
                deviceToAdd.process = ((newDevice.nilm?.process) != nil)
                deviceToAdd.type = newDevice.type
                
                realm.add(deviceToAdd)
                try? realm.commitWrite()
            } else { // when device already saved in realm, then update fields
            //find realm device
                let realmDevice = realmDevices.filter {
                    $0.mac == fetchedMac
                }.first
                
                let newDevice = devices.filter {
                    $0.mac == fetchedMac
                }.first
                
                guard let realmDevice = realmDevice, let newDevice = newDevice else {
                    return
                }
                try? realm.write {
                    realmDevice.mac = newDevice.mac
                    realmDevice.token = newDevice.token
                }
            }
        }
    }
    
    func retryLogCurrentUser(userEmail: String, hashedPassword: String, url: String){
        
        let credentials = LocalLoginCredentials(login: userEmail,
                                                password: hashedPassword)
        networkingService.post(url: url,
                               jsonBody: credentials,
                               onCompletion: { [weak self] (response: LoginResponse) in
            guard let self = self else { return }
            self.currentController = self.instantiateTopMostViewController()

            switch response.status {
            case .ok:
               
                
                guard let data = response.data else {return}
                
                //save user devices - new way by update
                self.updateUserDevices(devices: data)
                //old way by delete and add
                //self.saveAllUserDevices(devices: data)
                
            case .fail:
                let alert = UIAlertController.showAlertWithCancelButton(title: "Login Error", message: response.message ?? "Something went wrong!")
                self.currentController?.present(alert, animated: true, completion: nil)
            }
        }, onError: { error in
            print("🚫 Error occured: \(error)🚫")
        })
    }
}

