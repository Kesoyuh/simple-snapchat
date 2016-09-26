//
//  CameraViewController.swift
//  snapchat
//
//  Created by Boqin Hu on 27/08/2016.
//  Copyright © 2016 Boqin Hu. All rights reserved.
//

import UIKit
import AVFoundation
import Parse

class CameraViewController : UIViewController {
    
    var usingSimulator: Bool = true
    var captureSession : AVCaptureSession!
    var backCamera : AVCaptureDevice!
    var frontCamera : AVCaptureDevice!
    var currentDevice : AVCaptureDevice!
    var captureDeviceInputBack:AVCaptureDeviceInput!
    var captureDeviceInputFront:AVCaptureDeviceInput!
    var stillImageOutput:AVCaptureStillImageOutput!
    
    var cameraFacingback: Bool = true
    
    @IBOutlet var previewView: UIView!
    
    @IBOutlet weak var TakePicButton: UIButton!
    
    @IBOutlet weak var Flash: UIButton!
    
    @IBOutlet weak var FlipCamera: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(prefersStatusBarHidden())
        //loadCamera()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkIfUserIsLoggedIn()
    }
    
    func checkIfUserIsLoggedIn() {
        let currentUser = PFUser.current()
        
        if currentUser != nil {
            // User is logged in
            // Do nothing currently
        } else {
            // User is not logged in
            let loginRegisterController = LoginRegisterController()
            present(loginRegisterController, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden : Bool {
        return !(self.parent!.prefersStatusBarHidden)
    }
    
    
    
    func loadCamera() {
        captureSession = AVCaptureSession()
        captureSession.startRunning()
        
        if captureSession.canSetSessionPreset(AVCaptureSessionPresetHigh){
            captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        }
        let devices = AVCaptureDevice.devices()
        
        for device in devices! {
            if (device as AnyObject).hasMediaType(AVMediaTypeVideo){
                if (device as AnyObject).position == AVCaptureDevicePosition.back {
                    backCamera = device as! AVCaptureDevice
                }
                else if (device as AnyObject).position == AVCaptureDevicePosition.front{
                    frontCamera = device as! AVCaptureDevice
                }
            }
        }
        if backCamera == nil {
            print("The device doesn't have camera")
        }
        
        currentDevice = backCamera
        //var error:NSError?
        
        //create a capture device input object from the back and front camera
        do {
            captureDeviceInputBack = try AVCaptureDeviceInput(device: backCamera)
        }
        catch
        {
            
        }
        do {
            captureDeviceInputFront = try AVCaptureDeviceInput(device: frontCamera)
        }catch{
            
        }
        
        if captureSession.canAddInput(captureDeviceInputBack){
            captureSession.addInput(captureDeviceInputBack)
        } else {
            print("can't add input")
        }
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        captureSession.addOutput(stillImageOutput)
        let capturePreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        capturePreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        capturePreviewLayer?.frame = self.view.frame
        
        capturePreviewLayer?.bounds = self.view.bounds
        
        previewView.layer.addSublayer(capturePreviewLayer!)
        
    }
    
    
    @IBAction func Takepicture(_ sender: UIButton) {
        TakePicButton.isEnabled = true;
    }
    
    @IBAction func ChangeFlash(_ sender: UIButton){
        
    }
    
    
    
    @IBAction func Flip_Camera(_ sender: UIButton){
        
        cameraFacingback = !cameraFacingback
        if cameraFacingback {
            displayBackCamera()
        } else {
            displayFrontCamera()
        }
        
        
        
    }
    
    func displayBackCamera(){
        if captureSession.canAddInput(captureDeviceInputBack) {
            captureSession.addInput(captureDeviceInputBack)
        } else {
            captureSession.removeInput(captureDeviceInputFront)
            if captureSession.canAddInput(captureDeviceInputBack) {
                captureSession.addInput(captureDeviceInputBack)
            }
        }
        
    }
    
    func displayFrontCamera(){
        if captureSession.canAddInput(captureDeviceInputFront) {
            captureSession.addInput(captureDeviceInputFront)
        } else {
            captureSession.removeInput(captureDeviceInputBack)
            if captureSession.canAddInput(captureDeviceInputFront) {
                captureSession.addInput(captureDeviceInputFront)
            }
        }
    }
    
}

