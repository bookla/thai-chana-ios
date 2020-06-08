//
//  RequestViewController.swift
//  Check-In
//
//  Created by Book Lailert on 7/6/20.
//  Copyright © 2020 Book Lailert. All rights reserved.
//

import UIKit
import WebKit

class RequestViewController: UIViewController, WKNavigationDelegate {
    
    
    var unknownPlace = false

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
    
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closePage"), object: nil)
        if unknownPlace {
            if let placeID = UserDefaults.standard.string(forKey: "placeID") {
                if var currentData = UserDefaults.standard.object(forKey: "checkedIn") as? [String:[String:Any]] {
                    currentData[String(Date().timeIntervalSince1970)] = ["name":placeID, "date":Date(), "shopID": placeID]
                    UserDefaults.standard.set(currentData, forKey: "checkedIn")
                } else {
                    let newData = [String(Date().timeIntervalSince1970):["name":placeID, "date":Date(), "shopID": placeID]]
                    UserDefaults.standard.set(newData, forKey: "checkedIn")
                }
            }
        }
    }
    
    
    func checkInFailed(errorText:String = "Please try again later") {
        let alert = UIAlertController(title: "Check In Failed", message: errorText, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel) { (nil) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        
        self.present(alert, animated: true)
    }
    
    
    func combineScalars(list:[String.UnicodeScalarView.Element]) -> String{
        var output = ""
        for eachScalar in list {
            output += String(eachScalar)
        }
        return output
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        var placeName = "Unknown Place"
        var infoReady = false
        var loopCount = 0
        unknownPlace = true
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (readyTimer) in
            loopCount += 1
            webView.evaluateJavaScript("document.getElementById(\"__next\").children[0].children[0].children[0].children[0].children[2].children[0].innerText", completionHandler: { (mainReply: Any?, error: Error?) in
                infoReady = false
                if let name = mainReply as? String {
                    if name != "" {
                        print(name)
                        placeName = name
                        infoReady = true
                        self.unknownPlace = false
                    }
                } else {
                    webView.evaluateJavaScript("document.getElementById(\"__next\").children[0].children[0].children[1].innerText", completionHandler: { (response: Any?, error: Error?) in
                        if let error = response as? String {
                            if error == "ไม่พบกิจการ" {
                                self.unknownPlace = false
                                self.checkInFailed(errorText: "Incorrect Shop ID or Shop no longer exists.")
                                readyTimer.invalidate()
                            }
                        }
                    })
                }
                if infoReady {
                    if let placeID = UserDefaults.standard.string(forKey: "placeID") {
                        if var currentData = UserDefaults.standard.object(forKey: "checkedIn") as? [String:[String:Any]] {
                            currentData[String(Date().timeIntervalSince1970)] = ["name":placeName, "date":Date(), "shopID": placeID]
                            UserDefaults.standard.set(currentData, forKey: "checkedIn")
                        } else {
                            let newData = [String(Date().timeIntervalSince1970):["name":placeName, "date":Date(), "shopID": placeID]]
                            UserDefaults.standard.set(newData, forKey: "checkedIn")
                        }
                    }
                    if UserDefaults.standard.bool(forKey: "InAutoClose") {
                        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (nil) in
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    readyTimer.invalidate()
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
