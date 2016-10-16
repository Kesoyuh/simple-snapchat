//
//  QRReaderControllerViewController.swift
//  simple-snapchat
//
//  Created by Helen on 9/10/2016.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class QRReaderControllerViewController: UIViewController , AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(closeScanner))

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        let videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed();
            return;
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
        previewLayer.frame = view.layer.bounds;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        view.layer.addSublayer(previewLayer);
        
        captureSession.startRunning();
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    func closeScanner(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning();
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning();
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject;
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(userID: readableObject.stringValue);
        }
    }
    
    func found(userID: String) {
        let myID = FIRAuth.auth()?.currentUser?.uid
        print("QR reader get", userID)
        if isValidInput(inputID: userID) {
            print("Only execute if there is no special characters.")
            if userID != myID{
                
                var name : String?
                
                let userRef = FIRDatabase.database().reference().child("users").child(userID)
                userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot)
                    if snapshot.value != nil {
                        if let dictionary = snapshot.value as? [String: AnyObject]{
                            print("Dictionary is ", dictionary)
                            name = dictionary["name"] as? String
                            
                            let friendRef = FIRDatabase.database().reference().child("friendship").child(userID)
                            friendRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                if let dictionary = snapshot.value as? [String:AnyObject] {
                                    if (dictionary[myID!] != nil && dictionary[myID!] as? Int == 2)  {
                                        self.displayAlert(title: "Wrong Operation", message: "You and \(name!) already are friends.")
                                        
                                    }else{
                                        self.sendRequest(id: userID)
                                        self.displayAlert(title: "Request is sent!", message: "You sent a request to \(name!)! Wait for the confirmation..")
                                    }
                                }else{
                                    self.displayAlert(title: "Request is sent!", message: "You sent a request to \(name!)! Wait for the confirmation..")
                                    self.sendRequest(id: userID)
                                    
                                }
                            })
                            
                        }else{
                            self.displayAlert(title: "Invalid Cose", message: "This coede is not invalid!")
                        }
                    }
                    
                    
                })
            }else{
                self.displayAlert(title: "Wrong Operation", message: "You cannot send request to yourself!")

            }
        }else{
            self.displayAlert(title: "Invalid Cose", message: "This coede is not invalid!")
        }
    }
    
    func isValidInput(inputID: String) -> Bool{
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789")
        if inputID.rangeOfCharacter(from: characterset.inverted) != nil {
            print("String contains special charaters!")
            return false
        }else{
            return true
        }
    
    }
    
    func sendRequest(id:String){
        let fromID = (FIRAuth.auth()?.currentUser?.uid)!
        let toID = id
        
        // "0": wait for partner's acceptance
        // "1": receive a new request, the user can choose to accept or reject
        // "2": establish the friendship
        
        let senderFriendRef = FIRDatabase.database().reference().child("friendship").child(fromID)
        senderFriendRef.updateChildValues([toID : 0])
        let receiverFriendRef = FIRDatabase.database().reference().child("friendship").child(toID)
        receiverFriendRef.updateChildValues([fromID: 1])
        
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: {
            (alert: UIAlertAction!) in self.closeScanner()
        })
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }}
