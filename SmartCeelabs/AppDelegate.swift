//
//  AppDelegate.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 07/04/2021.
//

import UIKit
import Firebase
import RealmSwift
import GoogleSignIn
import KeychainSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var time: Int = 0
    weak var timer: Timer?
    let loginViewModel = LoginViewModel()
    let viewController = LoginViewController.instantiate()
    let userDefaults = UserDefaults.standard
    let keychain = KeychainSwift()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(chcekUserActivityTime), userInfo: nil, repeats: true)

        FirebaseApp.configure()
        
        let config = Realm.Configuration(
                // Set the new schema version. This must be greater than the previously used
                // version (if you've never set a schema version before, the version is 0).
                schemaVersion: 1,
                // Set the block which will be called automatically when opening a Realm with
                // a schema version lower than the one set above
                migrationBlock: { migration, oldSchemaVersion in
                    // We haven’t migrated anything yet, so oldSchemaVersion == 0
                    if (oldSchemaVersion < 1) {
                        // Nothing to do!
                        // Realm will automatically detect new properties and removed properties
                        // And will update the schema on disk automatically
                    }
            })

            // Tell Realm to use this new configuration object for the default Realm
            Realm.Configuration.defaultConfiguration = config

            // Now that we've told Realm how to handle the schema change, opening the file
            // will automatically perform the migration
//            let realm = try! Realm()
        
        //Set UIPageControll dost color globally
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.systemBlue
        
        
        
        
        let userDefaults = UserDefaults.standard
        let keychain = KeychainSwift()
        let userInstalledFirstTime = userDefaults.value(forKey: "firstTimeInstalled") as? Bool

        if userInstalledFirstTime == nil {
            userDefaults.setValue(true, forKey: "firstTimeInstalled")
            keychain.delete("refreshToken")
            keychain.delete("password")
        }
        
                
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
      var handled: Bool

        handled = GoogleSignIn.GIDSignIn.sharedInstance.handle(url)
      if handled {
        return true
      }

//       Handle other custom URL types.
//
//       If not handled by this app, return false.
      return false
    }
    
    @objc func chcekUserActivityTime() {
        let authType = userDefaults.string(forKey: "auth")

        let email = self.keychain.get("userEmail")
        let password = self.keychain.get("userPassword")
        
        guard let email = email, let password = password else {
            return
        }
        
        if time % 300 == 0 {
            if authType == "local" {
                loginViewModel.retryLogCurrentUser(userEmail: email, hashedPassword: password, url: UrlEnum.localAuthUrl.rawValue)
            }
        }
        print(time)
        time += 1
    }
}

