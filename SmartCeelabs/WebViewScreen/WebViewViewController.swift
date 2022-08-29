//
//  WebViewViewController.swift
//  SmartCeelabs
//
//  Created by Dávid Baľak on 05/04/2022.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        // Do any additional setup after loading the view.
    }
    
    func setupWebView() {
        guard let url = URL(string: "https://ceelabs.com/") else {return}
        webView.load(URLRequest(url: url))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    static func instantiate() -> Self {
        return UIStoryboard(name: "WebViewScreenView", bundle: nil).instantiateViewController(withIdentifier: "WebViewViewController") as! Self
    }
}
