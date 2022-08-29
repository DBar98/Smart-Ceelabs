//
//  ViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 07/04/2021.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController {

    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var googleLogInButton: GIDSignInButton!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var userPasswordField: UITextField!

    
    var viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad(controller: self)

        self.setupLoginButton()
        
        userNameField.alpha = 0.7
        userPasswordField.alpha = 0.7
        
        let userImage = UIImage(systemName: "person.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.darkGray)
        let passwordImage = UIImage(systemName: "key.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.darkGray)

        
        guard let userImage = userImage, let pswImage = passwordImage else { return }
        
        addLeftImageTo(txtField: userNameField, andImage: userImage)
        addLeftImageTo(txtField: userPasswordField, andImage: pswImage)
        
        self.setupUI()

    }
    
    private func setupUI() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        // provides google sing on button correct functionality
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupLoginButton() {
        loginButton.layer.cornerRadius = 10
        loginButton.titleLabel?.textColor = UIColor(red: 0, green: 182, blue: 255)
    }
    
    @IBAction func logUserIn(_ sender: Any) {
        guard let userEmail = userNameField.text, let password = userPasswordField.text else { return }
        
        viewModel.logUserIn(userEmail: userEmail, password: password, url: "https://backend.merito.tech/api2-r/auth/local", controller: self, loginType: .local, isRefreshing: false)
    }
    
    func addLeftImageTo(txtField: UITextField, andImage img: UIImage) {
        let leftImageView = UIImageView(frame: CGRect(x: 4.0, y: 0.0, width: 10, height: 10))
        leftImageView.image = img
        txtField.leftView = leftImageView
        txtField.leftViewMode = .always
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        self.view.frame.origin.y = 0

        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            
            self.view.frame.origin.y -= (keyboardHeight - loginButton.frame.origin.y) + 20
        }
    }
    
    @objc private func keyboardWillHide() {
        self.view.frame.origin.y = 0
    }
    
    @IBAction func googleLogInPressed(_ sender: Any) {
        viewModel.logUserIn(userEmail: "", password: "", url: "", controller: self, loginType: .google, isRefreshing: false)
        dismissKeyboard()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    static func instantiate() -> Self {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginController") as! Self
    }
}

