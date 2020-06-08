//
//  HistoryViewController.swift
//  Check-In
//
//  Created by Book Lailert on 7/6/20.
//  Copyright © 2020 Book Lailert. All rights reserved.
//

import UIKit

class HistoryViewController: UITableViewController {

    var placeByDate = [Date:[String:[String:Any]]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
        if let data = UserDefaults.standard.object(forKey: "history") as? [String:[String: Any]] {
            let keys = Array(data.keys.sorted().reversed())
            for eachKey in keys {
                let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
                calendar.timeZone = .current
                let startOfDay = calendar.startOfDay(for: (data[eachKey]!["in"] as! Date))
                if placeByDate.keys.contains(startOfDay) {
                    placeByDate[startOfDay]![eachKey] = data[eachKey]!
                } else {
                    placeByDate[startOfDay] = [eachKey: data[eachKey]!]
                }
            }
        } else {
            let alert = UIAlertController(title: "No History", message: "Have have not checked in to anywhere yet.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel) { (nil) in
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        print(placeByDate)
        // Do any additional setup after loading the view.
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return placeByDate.keys.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dates = Array(Array(placeByDate.keys).sorted().reversed())
        let currentKey = dates[section]
        let dateActivites = placeByDate[currentKey]
        return dateActivites?.keys.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryTableViewCell
        
        let dates = Array(Array(placeByDate.keys).sorted().reversed())
        let currentKey = dates[indexPath.section]
        let dateActivites = placeByDate[currentKey]
        let activitiesKeys = Array(Array(dateActivites!.keys).sorted().reversed())
        let currentActivityKey = activitiesKeys[indexPath.row]
        let currentActivity = dateActivites![currentActivityKey]
        
        cell.name.text = currentActivity!["name"] as? String
        
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "hh:mm:ss a"
        
        let inTime = currentActivity!["in"] as! Date
        cell.inTime.text = "In time : " + formatter.string(from: inTime)
        
        let outTime = currentActivity!["out"] as! Date
        cell.outTime.text = "Out time : " + formatter.string(from: outTime)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dates =  Array(Array(placeByDate.keys).sorted().reversed())
        let currentKey = dates[section]
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "EEEE d MMMM y"
        return formatter.string(from: currentKey)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dates =  Array(Array(placeByDate.keys).sorted().reversed())
        let currentKey = dates[indexPath.section]
        let dateActivites = placeByDate[currentKey]
        let activitiesKeys = Array(Array(dateActivites!.keys).sorted().reversed())
        let currentActivityKey = activitiesKeys[indexPath.row]
        let currentActivity = dateActivites![currentActivityKey]
        
        let shopID = currentActivity!["shopID"] as! String
        let shopName = currentActivity!["name"] as! String
        let inDate = (currentActivity!["in"] as! Date).description(with: .current)
        let outDate = (currentActivity!["out"] as! Date).description(with: .current)
        let alertText = "Shop ID: " + shopID + "\nShop Name: " + shopName + "\nChecked In: " + inDate + "\nChecked Out: " + outDate
        
        let alert = UIAlertController(title: "Activity Details", message: alertText, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
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
