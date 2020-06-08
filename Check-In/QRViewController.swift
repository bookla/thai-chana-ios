//
//  QRViewController.swift
//  Check-In
//
//  Created by Book Lailert on 7/6/20.
//  Copyright © 2020 Book Lailert. All rights reserved.
//

import UIKit
import AVFoundation

func invalidToken(currentVC: UIViewController, dismiss:Bool = true) {
    let alert = UIAlertController(title: "Invalid Token Link", message: "The token you entered incorrect", preferredStyle: .alert)
    let dismiss = UIAlertAction(title: "OK", style: .cancel) { (action) in
        if dismiss {
            currentVC.dismiss(animated: true, completion: nil)
        }
    }
    alert.addAction(dismiss)
    currentVC.present(alert, animated: true, completion: nil)
}

func getToken(currentVC: UIViewController, reset:Bool = false, completionHandler: @escaping (_ token: String) -> Void) {
    if ((UserDefaults.standard.string(forKey: "checkInToken") as? String) != nil) && !reset {
        completionHandler(UserDefaults.standard.string(forKey: "checkInToken") as! String)
    } else {
        let alert = UIAlertController(title: "Token Required", message: "Check in using your browser, then copy and paste the URL into the text field to start using the app.", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.text = "qr.thaichana.com/...."
        }
        

        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (alertAction) in
            let textField = alert.textFields![0]
            if textField.text != nil {
                let text = textField.text!
                if let startIndex = text.endIndex(of: "&token=") {
                    if let endIndex = text.index(of: "&mode=line") {
                        let subscriptStart = text.index(text.startIndex, offsetBy: startIndex.utf16Offset(in: text))
                        let subscriptEnd = text.index(text.startIndex, offsetBy: endIndex.utf16Offset(in: text))
                        let token = String(text[subscriptStart..<subscriptEnd])
                        UserDefaults.standard.set(token, forKey: "checkInToken")
                        completionHandler(token)
                    } else {
                        if reset {
                            invalidToken(currentVC: currentVC, dismiss: false)
                        } else {
                            invalidToken(currentVC: currentVC)
                        }
                    }
                } else {
                    if reset {
                        invalidToken(currentVC: currentVC, dismiss: false)
                    } else {
                        invalidToken(currentVC: currentVC)
                    }
                }
            } else {
                if reset {
                    invalidToken(currentVC: currentVC, dismiss: false)
                } else {
                    invalidToken(currentVC: currentVC)
                    currentVC.dismiss(animated: true, completion: nil)
                }
            }
        }))
        
        if reset {
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        }

        currentVC.present(alert, animated: true, completion: nil)
    }
}

class QRViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession:AVCaptureSession = AVCaptureSession()
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var scanning = false
    
    var currentlyCheckedIn = [[String:[String:Any]]]()
    
    
    func scan() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
         
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
         
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addInput(input)
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            DispatchQueue.global().async {
                self.captureSession.startRunning()
                DispatchQueue.main.async {
                    self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                    self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    self.videoPreviewLayer?.frame = self.view.layer.bounds
                    self.view.layer.addSublayer(self.videoPreviewLayer!)
                }
            }
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
    }
    
    
    func invalidQRCode() {
        let alert = UIAlertController(title: "Invalid QR Code", message: "The QR Code you scanned is not a supported QR Code.", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "OK", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(dismiss)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func getShopID(stringURL: String) -> String? {
        if let index = stringURL.endIndex(of: "shopId") {
            let startIndex = stringURL.index(stringURL.startIndex, offsetBy: index.utf16Offset(in: stringURL) + 1)
            return String(stringURL[startIndex...])
        } else {
            invalidQRCode()
            return nil
        }
    }
    
    
    func alreadyCheckedIn(placeName: String) {
        let alert = UIAlertController(title: "Already Checked In", message: "You are already checked into " + placeName, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel) { (nil) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func checkIn(stringURL: String) {
        if let shopID = getShopID(stringURL: stringURL) {
            if let data = UserDefaults.standard.object(forKey: "checkedIn") as? [String:[String:Any]] {
                for key in data.keys {
                    if data[key]!["shopID"] as! String == shopID {
                        self.alreadyCheckedIn(placeName: data[key]!["name"] as! String)
                        return
                    }
                }
            }
            getToken(currentVC: self) { (token) in
                let urlToOpen = "https://qr.thaichana.com/callback?appId=0001&shopId=" + shopID + "&type=checkin&token=" + token
                print(urlToOpen)
                UserDefaults.standard.set(urlToOpen, forKey: "currentURL")
                UserDefaults.standard.set(shopID, forKey: "placeID")
                self.performSegue(withIdentifier: "openLink", sender: nil)
                print(shopID)
            }
        } else {
            return
        }
    }
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if !scanning {
            return
        }
        scanning = false
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if let stringData = metadataObj.stringValue{
                print(stringData)
                if isURLValid(stringURL: stringData){
                    self.checkIn(stringURL: stringData)
                } else {
                    self.invalidQRCode()
                }
            }
        }
    }
    
    
    func isURLValid(stringURL: String) -> Bool {
        if !stringURL.contains("qr.thaichana.com") {
            return false
        }
        if !stringURL.contains("shopId=") {
            return false
        }
        return true
    }
    
    @objc func close(notif: NSNotification) {
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { (nil) in
            self.dismiss(animated: true, completion: nil)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scan()
        scanning = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.close), name: NSNotification.Name(rawValue: "closePage"), object: nil)
        // Do any additional setup after loading the view.
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
