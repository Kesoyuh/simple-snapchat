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
import Firebase

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
    var ImageCaptured: UIImage!
    var cameraState:Bool = true
    var flashOn:Bool = false
    
    /**
     The outlet of UIView of the CameraView.
     */
    @IBOutlet var previewView: UIView!
    
    /**
     The outlet of the take picture button.
     */
    @IBOutlet weak var TakePicButton: UIButton!
    
    /**
     The outlet of the configure flash button.
     */
    @IBOutlet weak var Flash: UIButton!
    
    /**
     The outlet of the flip camera button.
     */
    @IBOutlet weak var FlipCamera: UIButton!
    
    /**
     The action button to scroll to the chat view.
     */
    @IBAction func Jump_to_chat(_ sender: UIButton) {
        let scrollView = self.view.superview?.superview?.superview as? UIScrollView
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            scrollView!.contentOffset.x = 0.0
            }, completion: nil)
    }
    
    /**
     The action button to scroll to the story view.
     */
    @IBAction func Jump_to_story(_ sender: UIButton) {
        let scrollView = self.view.superview?.superview?.superview as? UIScrollView
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            scrollView!.contentOffset.x += self.view.frame.width
            
            }, completion: nil)
    }
    
    /**
     The action button to scroll to the my information view.
     */
    @IBAction func toAddfriend(_ sender: UIButton) {
        let scrollView = self.view.superview as? UIScrollView
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            scrollView!.contentOffset.y = 0.0
            }, completion: nil)


    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        loadCamera()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkIfUserIsLoggedIn()
    }
    
    /**
     Method to check whether user is logged in.
     */
    func checkIfUserIsLoggedIn() {
        
        if FIRAuth.auth()?.currentUser?.uid != nil {
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

    /**
     The method to load camera.
     */
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
        configureFlash()
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
    
    /**
     The method to realize the shutter function.
     */
    @IBAction func Takepicture(_ sender: UIButton) {
        TakePicButton.isEnabled = true;
        cameraState = false
        if !captureSession.isRunning {
            return
        }
        if let videoConnection = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo){
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: {(sampleBuffer,error) -> Void in
                if sampleBuffer != nil {
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                let dataProvider = CGDataProvider(data: imageData as! CFData)
                let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                self.ImageCaptured = UIImage(cgImage:cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
                    //self.captureSession.stopRunning()
                self.performSegue(withIdentifier: "test", sender: self)}
            })
        }
    }
    
    /**
     The method to realise opening and closing camera flash.
     */
    @IBAction func ChangeFlash(_ sender: UIButton){
        flashOn = !flashOn
        if flashOn {
            self.Flash.setImage(UIImage(named: "Flash_on"), for: UIControlState.normal)
        }
        else {
            self.Flash.setImage(UIImage(named: "Flash_off"), for: UIControlState.normal)
        }
            self.configureFlash()
    }
    
    /**
     The method to realize changing the camera direction.
     */
    @IBAction func Flip_Camera(_ sender: UIButton){
        
        cameraFacingback = !cameraFacingback
        if cameraFacingback {
            displayBackCamera()
            self.FlipCamera.setImage(UIImage(named:"Camera flip"), for: UIControlState.normal)
            
        } else {
            
            self.FlipCamera.setImage(UIImage(named:"Camera_flip_self"), for: UIControlState.normal)
            displayFrontCamera()
        }
    }
    
    /**
     The method to load back camera.
     */
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
    
    /**
     The method to load front camera.
     */
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
    
    /**
     The method to configure flash light.
     */
    func configureFlash(){
        do {
            try backCamera.lockForConfiguration()
        } catch {
            
        }
        if backCamera.hasFlash {
            if flashOn {
                if backCamera.isFlashModeSupported(AVCaptureFlashMode.on){
                backCamera.flashMode = AVCaptureFlashMode.on
                }
            }else {
                if backCamera.isFlashModeSupported(AVCaptureFlashMode.off){
                    backCamera.flashMode = AVCaptureFlashMode.off
                    //flashOn = false
                }
                
            }
        }
        backCamera.unlockForConfiguration()
    }
    
    /**
     The method to realise camera focusing.
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchpoint = touches.first
//        var screenSize = previewView.bounds.size
//        let location = touchpoint?.location(in: self.view)
        let x = (touchpoint?.location(in: self.view).x)! / self.view.bounds.width
        let y = (touchpoint?.location(in: self.view).y)! / self.view.bounds.height
        
//        var locationX = location?.x
//        var locationY = location?.y
        
        focusOnPoint(x: x, y: y)
    }
    
    /**
     The algorithm to reasise autofocus .
     */
    func focusOnPoint(x: CGFloat, y:CGFloat){
        let focusPoint = CGPoint(x: x, y: y)
        if cameraFacingback {
            currentDevice = backCamera
        }
        else {
            currentDevice = frontCamera
        }
        do {
            try currentDevice.lockForConfiguration()
        }catch {
            
        }
        
        if currentDevice.isFocusPointOfInterestSupported{
            
            currentDevice.focusPointOfInterest = focusPoint
        }
        if currentDevice.isFocusModeSupported(AVCaptureFocusMode.autoFocus)
        {
            currentDevice.focusMode = AVCaptureFocusMode.autoFocus
        }
        if currentDevice.isExposurePointOfInterestSupported
        {
            currentDevice.exposurePointOfInterest = focusPoint
        }
        if currentDevice.isExposureModeSupported(AVCaptureExposureMode.autoExpose) {
            currentDevice.exposureMode = AVCaptureExposureMode.autoExpose
        }
        currentDevice.unlockForConfiguration()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "test"{
            let previewController = segue.destination as! PreviewController
            previewController.capturedPhoto = self.ImageCaptured            
        }
}
}
    
