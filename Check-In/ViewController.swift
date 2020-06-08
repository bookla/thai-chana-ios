//
//  ViewController.swift
//  Check-In
//
//  Created by Book Lailert on 7/6/20.
//  Copyright © 2020 Book Lailert. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVCaptureMetadataOutputObjectsDelegate {
    
    
    var currentlyCheckedIn = [String:[String:Any]]()


    override func viewDidLoad() {
        super.viewDidLoad()
        //self.performSegue(withIdentifier: "register", sender: nil)
        
        checkInTable.dataSource = self
        checkInTable.delegate = self
        
        checkInOut.layer.cornerRadius = 15
        checkInOut.clipsToBounds = true
        
        //historyOut.layer.borderColor = UIColor.lightGray.cgColor
        //historyOut.layer.borderWidth = 0.5
        //settingsOut.layer.borderColor = UIColor.lightGray.cgColor
        //settingsOut.layer.borderWidth = 0.5
        
        checkInOut.backgroundColor = UIColor(displayP3Red: 126/255, green: 217/255, blue: 98/255, alpha: 1.0)
        navigationController?.setNavigationBarHidden(true, animated: true)
        //LOAD DATA
        if let data = UserDefaults.standard.object(forKey: "checkedIn") as? [String:[String:Any]] {
            currentlyCheckedIn = data
            print(currentlyCheckedIn)
        } else {
            print("No data or invalid data")
        }
        checkInTable.tableFooterView = UIView()
        checkInTable.reloadData()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (nil) in
            if let data = UserDefaults.standard.object(forKey: "checkedIn") as? [String:[String:Any]] {
                self.currentlyCheckedIn = data
            } else {
                print("No data or invalid data")
            }
            self.checkInTable.reloadData()
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Currently Checked In"
    }
    
    func time(string: Int) -> String {
        if String(string).count == 1 {
            return "0" + String(string)
        } else {
            return String(string)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if currentlyCheckedIn.keys.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CheckedInTableViewCell
            
            let keys = Array(currentlyCheckedIn.keys).sorted()
            let currentKey = keys[indexPath.row]
            let name = currentlyCheckedIn[currentKey]!["name"] as! String
            let date = currentlyCheckedIn[currentKey]!["date"] as! Date
            let secondsDifference = Date().timeIntervalSince(date)
            let (h, m, s) = secondsToHoursMinutesSeconds(seconds: Int(secondsDifference))
            let timeString = "Time: " + time(string: h) + ":" + time(string: m) + ":" + time(string: s)
            cell.PlaceName.text = name
            cell.Time.text = timeString
            cell.checkOutButtonOut.tag = indexPath.row
            cell.checkOutButtonOut.addTarget(self, action: #selector(checkOut(_:)), for: .touchUpInside)
            
            return cell
        } else {
            let specialCell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! NotCheckedInTableViewCell
            
            return specialCell
        }
        
        
    }
    
    func saveHistory(currentKey:String) {
        let shopName = currentlyCheckedIn[currentKey]!["name"] as! String
        let shopID = currentlyCheckedIn[currentKey]!["shopID"] as! String
        let signedInDate = currentlyCheckedIn[currentKey]!["date"] as! Date
        let signedOutDate = Date()
        let info = ["name": shopName, "shopID": shopID, "in": signedInDate, "out": signedOutDate] as [String : Any]
        if var data = UserDefaults.standard.object(forKey: "history") as? [String:[String: Any]] {
            data[String(signedInDate.timeIntervalSince1970)] = info
            UserDefaults.standard.set(data, forKey: "history")
        } else {
            let newData = [String(signedInDate.timeIntervalSince1970):info]
            UserDefaults.standard.set(newData, forKey: "history")
        }
    }
    
    @objc func checkOut(_ sender:UIButton) {
        let keys = Array(currentlyCheckedIn.keys).sorted()
        let currentKey = keys[sender.tag]
        let shopId = currentlyCheckedIn[currentKey]!["shopID"] as! String
        getToken(currentVC: self) { (token) in
            let urlToOpen = "https://qr.thaichana.com/callback?appId=0001&shopId=" + shopId + "&type=checkout&token=" + token
            print(urlToOpen)
            UserDefaults.standard.set(urlToOpen, forKey: "currentURL")
            self.performSegue(withIdentifier: "checkOutLink", sender: nil)
            if !UserDefaults.standard.bool(forKey: "DisableHistory") {
                self.saveHistory(currentKey: currentKey)
            }
            self.currentlyCheckedIn.removeValue(forKey: currentKey)
            
            UserDefaults.standard.set(self.currentlyCheckedIn, forKey: "checkedIn")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentlyCheckedIn.keys.count > 0 {
            return currentlyCheckedIn.keys.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBOutlet var checkInTable: UITableView!
    
    @IBAction func checkInButton(_ sender: Any) {
        checkInOut.backgroundColor = UIColor(displayP3Red: 126/255, green: 217/255, blue: 98/255, alpha: 1.0)
        self.performSegue(withIdentifier: "readQR", sender: nil)
    }
    
    @IBAction func viewHistory(_ sender: Any) {
        historyOut.backgroundColor = UIColor(red: 242/255, green: 246/255, blue: 250/255, alpha: 1.0)
        if UserDefaults.standard.bool(forKey: "DisableHistory") {
            let alert = UIAlertController(title: "History Disabled", message: "You can enabled history in settings", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel) { (nil) in
                print("OK")
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: "showHistory", sender: nil)
        }
    }
    
    @IBOutlet var settingsOut: UIButton!
    @IBOutlet var historyOut: UIButton!
    
    
    @IBAction func historyDown(_ sender: Any) {
        historyOut.backgroundColor = UIColor(red: 217/255, green: 220/255, blue: 224/255, alpha: 1.0)
    }
    @IBAction func historyUpOut(_ sender: Any) {
        historyOut.backgroundColor = UIColor(red: 242/255, green: 246/255, blue: 250/255, alpha: 1.0)
    }
    @IBAction func settingsDown(_ sender: Any) {
        settingsOut.backgroundColor = UIColor(red: 217/255, green: 220/255, blue: 224/255, alpha: 1.0)
    }
    @IBAction func settingsUpIn(_ sender: Any) {
        settingsOut.backgroundColor = UIColor(red: 242/255, green: 246/255, blue: 250/255, alpha: 1.0)
    }
    @IBAction func settingsUpOut(_ sender: Any) {
        settingsOut.backgroundColor = UIColor(red: 242/255, green: 246/255, blue: 250/255, alpha: 1.0)
    }
    
    @IBAction func checkInDown(_ sender: Any) {
        checkInOut.backgroundColor = UIColor(red: 108/255, green: 187/255, blue: 85/255, alpha: 1.0)
    }
    @IBAction func checkInUpOut(_ sender: Any) {
        checkInOut.backgroundColor = UIColor(displayP3Red: 126/255, green: 217/255, blue: 98/255, alpha: 1.0)
    }
    
    
    
    
    @IBOutlet var checkInOut: UIButton!
}

