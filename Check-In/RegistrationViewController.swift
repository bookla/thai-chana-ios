//
//  RegistrationViewController.swift
//  Check-In
//
//  Created by Book Lailert on 8/6/20.
//  Copyright © 2020 Book Lailert. All rights reserved.
//

import UIKit
import WebKit

class RegistrationViewController: UIViewController, WKNavigationDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        let webView = WKWebView()
        webView.navigationDelegate = self
        self.view = webView
        
        let url = URL(string: "https://qr.thaichana.com/?appId=0001&shopId=S0000000001")!
        print(url)
        
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = false
        
        // Do any additional setup after loading the view.
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Loaded")
        
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (tokenTimer) in
            webView.evaluateJavaScript("function getUrlParams() { var paramMap = {}; if (location.search.length === 0) { return paramMap; } var parts = location.search.substring(1).split(\"&\"); for (var i = 0; i < parts.length; i ++) { var component = parts[i].split(\"=\"); paramMap [decodeURIComponent(component[0])] = decodeURIComponent(component[1]); } return paramMap; }; getUrlParams()") { (params, error) in
                if let parameters = params as? [String: String] {
                    if let token = parameters["token"] {
                        if token != "" {
                            UserDefaults.standard.set(token, forKey: "checkInToken")
                            tokenTimer.invalidate()
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }
        
        
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
