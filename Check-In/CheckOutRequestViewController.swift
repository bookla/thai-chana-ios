//
//  CheckOutRequestViewController.swift
//  Check-In
//
//  Created by Book Lailert on 7/6/20.
//  Copyright © 2020 Book Lailert. All rights reserved.
//

import UIKit
import WebKit

class CheckOutRequestViewController: UIViewController, WKNavigationDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        let webView = WKWebView()
        webView.navigationDelegate = self
        self.view = webView
        
        if let urlToOpen = UserDefaults.standard.string(forKey: "currentURL") {
            let url = URL(string: urlToOpen)!
            print(url)
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = false
        }
        // Do any additional setup after loading the view.
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (checkTimer) in
            webView.evaluateJavaScript("document.getElementById(\"__next\").children[0].children[0].children[0].children[1].children[0].innerText", completionHandler: { (mainReply: Any?, error: Error?) in
                if let response = mainReply as? String {
                    if response == "เช็คเอาท์แล้ว" {
                        if UserDefaults.standard.bool(forKey: "OutAutoClose") {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                
            })
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
