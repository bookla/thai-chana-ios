//
//  SettingsViewController.swift
//  Check-In
//
//  Created by Book Lailert on 7/6/20.
//  Copyright © 2020 Book Lailert. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        getToken(currentVC: self) { (token) in
            self.userToken.text = token
        }
        checkInOut.isOn = UserDefaults.standard.bool(forKey: "InAutoClose")
        checkOutOut.isOn = UserDefaults.standard.bool(forKey: "OutAutoClose")
        historyOut.isOn = !UserDefaults.standard.bool(forKey: "DisableHistory")
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet var userToken: UILabel!
    
    @IBOutlet var checkInOut: UISwitch!
    @IBAction func checkInOption(_ sender: Any) {
        UserDefaults.standard.set(checkInOut.isOn, forKey: "InAutoClose")
    }
    
    @IBOutlet var checkOutOut: UISwitch!
    @IBAction func checkOutOption(_ sender: Any) {
        UserDefaults.standard.set(checkOutOut.isOn, forKey: "OutAutoClose")
    }
    
    @IBOutlet var historyOut: UISwitch!
    @IBAction func historyOption(_ sender: Any) {
        UserDefaults.standard.set(nil, forKey: "history")
        UserDefaults.standard.set(!historyOut.isOn, forKey: "DisableHistory")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 && indexPath.section == 0 {
            getToken(currentVC: self) { (token) in
                UIPasteboard.general.string = token
                let alert = UIAlertController(title: "Copied", message: "Token copied to clipboard", preferredStyle: .alert)
                self.present(alert, animated: true) {
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (nil) in
                        alert.dismiss(animated: true, completion: nil)
                    }
                }
            }
        } else if indexPath.section == 0 {
            if indexPath.row == 1 {
                getToken(currentVC: self, reset: true) { (newToken) in
                    print(newToken)
                }
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 1 {
                let alert = UIAlertController(title: "Clearing History", message: "", preferredStyle: .alert)
                self.present(alert, animated: true) {
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (nil) in
                        alert.dismiss(animated: true, completion: nil)
                    }
                }
                UserDefaults.standard.set(nil, forKey: "history")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
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
