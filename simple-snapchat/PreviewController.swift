//
//  PreviewController.swift
//  simple-snapchat
//
//  Created by Boqin Hu on 29/9/16.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class PreviewController: UIViewController, UIPickerViewDataSource ,UIPickerViewDelegate {
    
    
    @IBOutlet weak var ImageEdit: UIImageView!
    @IBOutlet weak var CancleButton: UIButton!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var text_on_image: UITextView!
    @IBOutlet weak var Image_Text: UIButton!
    @IBOutlet weak var Draw: UIButton!
    @IBAction func selectDuration(_ sender: AnyObject) {
        self.DurationPick.isHidden = false
    }
    @IBOutlet weak var DurationPick: UIPickerView!
    @IBAction func quit(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func SaveButton(_ sender: UIButton) {
        self.SaveImage()
        saveToFirebase()
    }
    
    @IBAction func Sendtotest(_ sender: UIButton) {
        let sendtocontroller = SendToController()
        sendtocontroller.images.append(self.ImageEdit.image!)
        let navController = UINavigationController(rootViewController: sendtocontroller)
        present(navController, animated: true, completion: nil)
    }
    @IBAction func enable_draw(_ sender: UIButton) {
        
        if enabledrawing == true {
            enabledrawing = false
            self.ImageEdit.isUserInteractionEnabled = true
        }else {
            enabledrawing = true
            self.ImageEdit.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func Image_edit_text(_ sender: UIButton) {
        if enabletexting == true {
            enabletexting = false
            self.text_on_image.becomeFirstResponder()
            self.text_on_image.isHidden = false
        } else {
            enabletexting = true
            self.text_on_image.endEditing(true)
            self.text_on_image.isHidden = true
        }
        
    }
    
    @IBOutlet weak var TextX: NSLayoutConstraint!
    
    @IBOutlet weak var TextY: NSLayoutConstraint!
    @IBAction func Imagetextdrag(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        sender.view?.center = CGPoint(x:sender.view!.center.x, y:sender.view!.center.y+translation.y)
        sender.setTranslation(CGPoint.init(x: 0.0, y: 0.0), in: self.view)
        self.TextX.constant += translation.x
        self.TextY.constant += translation.y
    }
    
    var capturedPhoto :UIImage!
    var pictureid : Int = 0
    var pic_duaration = 3
    var pickoption  = [1,2,3,4,5,6,7,8]
    var image_sending :UIImage!
    var test_image : UIImage!
    
    var isDrawing : Bool! = false
    var enabledrawing : Bool! = true
    var enabletexting : Bool! = true
    var finalPoint: CGPoint!
    var lineWidth: CGFloat = 4.0
    
    let red: CGFloat = 255.0/255.0
    let green: CGFloat = 0.0/255.0
    let blue: CGFloat = 0.0/255.0


    override func viewDidLoad() {
        super.viewDidLoad()
        DurationPick.delegate = self
        ImageEdit.image = capturedPhoto
        self.DurationPick.isHidden = true
        self.text_on_image.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ImageEdit.image = capturedPhoto
        

    }
    func saveToFirebase() {
        let uid = FIRAuth.auth()?.currentUser?.uid
        var username = String()
        
        // Create story reference
        let snapsRef = FIRDatabase.database().reference().child("snaps")
        FIRDatabase.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                username = dictionary["name"] as! String
            }
        })
        
        let imageName = NSUUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("snaps").child(imageName)
        //let image = ImageEdit.image!
        let image = self.captureScreen()
        let uploadData = UIImagePNGRepresentation(image)
        
        storageRef.put(uploadData!, metadata: nil, completion: { (metaData, error) in
            
            if error != nil {
                print(error)
                return
            } else {
            
                // update database after successfully uploaded
                let snapRef = snapsRef.childByAutoId()
                if let imageURL = metaData?.downloadURL()?.absoluteString {
                    snapRef.updateChildValues(["userID": uid!, "username": username, "imageURL": imageURL, "timer": self.pic_duaration], withCompletionBlock: {(error, ref) in
                        if error != nil {
                            print(error)
                            return
                        }
                        
                        
                    })
                }
                
            }
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ImageEdit.image = capturedPhoto
    }
    
    // Draw view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isDrawing = false
        self.DurationPick.isHidden = true
        if self.text_on_image.hasText
        {
            //self.ImageEdit.addSubview(self.text_on_image)
            self.enabletexting = true
            self.text_on_image.endEditing(false)
            
        } else {
            self.text_on_image.isHidden = true
            self.enabletexting = true
            self.text_on_image.endEditing(false)

        }
        self.text_on_image.endEditing(true)
        if let e = event?.touches(for: self.ImageEdit){
        if let touch = e.first {
            finalPoint = touch.preciseLocation(in: self.ImageEdit)
        }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isDrawing = true
        if let e = event?.touches(for: self.ImageEdit){
        if let touch = e.first{
            if let d = self.ImageEdit {
                let currentCoordinate = touch.preciseLocation(in: d)
                //UIGraphicsBeginImageContext(d.bounds.size)
                UIGraphicsBeginImageContextWithOptions(d.bounds.size, false, 0.0)
                d.image?.draw(in: CGRect.init(x: 0, y: 0, width: d.bounds.width, height: d.bounds.height))
                UIGraphicsGetCurrentContext()?.move(to: finalPoint)
                UIGraphicsGetCurrentContext()?.addLine(to: currentCoordinate)
                UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.round)
                UIGraphicsGetCurrentContext()?.setLineWidth(lineWidth)
                UIGraphicsGetCurrentContext()?.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
                UIGraphicsGetCurrentContext()?.strokePath()
                d.image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                finalPoint = currentCoordinate
            }
            }
        }
        
    }
    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if(!self.isDrawing){
//        if let touch = touches.first{
//            print(touch.view)
//            if let d = ImageEdit {
//                let currentCoordinate = touch.preciseLocation(in: d)
//                UIGraphicsBeginImageContext(d.frame.size)
//                d.image?.draw(in: CGRect.init(x: 0, y: 0, width: d.frame.width, height: d.frame.height))
//                UIGraphicsGetCurrentContext()?.move(to: finalPoint)
//                UIGraphicsGetCurrentContext()?.addLine(to: currentCoordinate)
//                UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.round)
//                UIGraphicsGetCurrentContext()?.setLineWidth(lineWidth)
//                UIGraphicsGetCurrentContext()?.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
//                UIGraphicsGetCurrentContext()?.strokePath()
//                d.image = UIGraphicsGetImageFromCurrentImageContext()
//                UIGraphicsEndImageContext()
//            }
//        }
//        }
//    }
    
    // Duration pick view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickoption.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
        return "\(pickoption[row])second"}
        else {
            return "\(pickoption[row])seconds"
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.pic_duaration = pickoption[row]
        self.DurationPick.isHidden = true
    }
    
    func SaveImage(){
        let saveQueue = DispatchQueue(label: "saveQueue",attributes: .concurrent)
        saveQueue.async {
            let image : UIImage! = self.ImageEdit.image
            //self.ImageEdit.addSubview(self.text_on_image)
            let image1 = self.captureScreen()
            self.image_sending = self.ResizeImage(image: image, targetSize: CGSize.init(width: 370.0, height: 647.0))
//            let imageData = UIImageJPEGRepresentation(image, 0.1)
//            let imageData2 = UIImageJPEGRepresentation(self.image_sending, 1)
            let imageData3 = UIImageJPEGRepresentation(image1, 0.1)
            let contextManaged = self.getContext()
            let a = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: contextManaged) as! Photo
            a.photo_data = imageData3 as NSData?
            do {
                try contextManaged.save()
            } catch{
                
            }
            //print(a.value(forKey: "photo_id"))
        }
        self.pictureid += 1
        self.save.isHidden = true
    }
    
    func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func getContext() -> NSManagedObjectContext {
        var context: NSManagedObjectContext?
        
        if #available(iOS 10.0, *) {
            context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        } else {
            // iOS 9.0 and below - however you were previously handling it
            guard let modelURL = Bundle.main.url(forResource: "Model", withExtension:"momd") else {
                fatalError("Error loading model from bundle")
            }
            guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
                fatalError("Error initializing mom from: \(modelURL)")
            }
            let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
            context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let docURL = urls[urls.endIndex-1]
            let storeURL = docURL.appendingPathComponent("Model.sqlite")
            do {
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
            
        }
        return context!
    }
    
    func captureScreen() -> UIImage {
        self.ImageEdit.addSubview(self.text_on_image)
        UIGraphicsBeginImageContextWithOptions(self.ImageEdit.bounds.size, false,0.0);
        let context = UIGraphicsGetCurrentContext();
        self.ImageEdit.layer.render(in: context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "haha"{
//            let testfetch = segue.destination as! Testcontroller
//            
//            //previewController.capturedPhoto = self.ImageCaptured
//        }
//    }
    

}
