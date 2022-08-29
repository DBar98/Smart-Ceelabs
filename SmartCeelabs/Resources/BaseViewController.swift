//
//  BaseViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 18/04/2022.
//

import UIKit

class BaseViewController: UIViewController {

    
    var onAppActiveBecome: (() -> ())? { return nil }
    var onAppWillEnterForeground: (() -> ())? { return nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector:#selector( onAppWillEnterForegroundFunc),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: UIApplication.shared)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onAppActiveBecomeFunc),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)

    }
    
    @objc func onAppActiveBecomeFunc() {
        onAppActiveBecome?()
    }
    
    @objc func onAppWillEnterForegroundFunc() {
        onAppWillEnterForeground?()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
