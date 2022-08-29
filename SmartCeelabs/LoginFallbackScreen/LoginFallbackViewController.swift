//
//  LoginFallbackViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 14/03/2022.
//

import UIKit

class LoginFallbackViewController: UIViewController, BiometricsSupportType {

    @IBOutlet weak var localLoginButton: UIButton!
    @IBOutlet weak var biometricsButton: UIButton!
    
    let defaults = UserDefaults.standard
    let viewmodel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func biometricsAttemptPressed(_ sender: Any) {
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginController") as! LoginViewController
        startBiometricAuth(controller: loginVC , onCompletion: {
            self.segueToTabBarWhenSuccessfulLogIn(controller: self)
        })
    }
    
    @IBAction func loginCredentialsAttemptPressed(_ sender: Any) {
        //Get back to credentials
        defaults.set("true", forKey: "useCredentials")
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginController") as! LoginViewController
        guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        keyWindow.rootViewController = loginVC
    }
    
    static func instantiate() -> Self {
        return UIStoryboard(name: "LoginFallbackView", bundle: nil).instantiateViewController(withIdentifier: "LoginFallbackViewController") as! Self
    }
}
