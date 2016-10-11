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
        self.performSegue(withIdentifier: "haha", sender: self)
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
    
    var capturedPhoto :UIImage!
    var pictureid : Int = 0
    var pic_duaration = 3
    var pickoption  = [1,2,3,4,5,6,7,8]
    
    
    var isDrawing : Bool! = false
    var enabledrawing : Bool! = true
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
        let image = ImageEdit.image!
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
            print(touch.view)
            if let d = self.ImageEdit {
                let currentCoordinate = touch.preciseLocation(in: d)
                UIGraphicsBeginImageContext(d.frame.size)
                d.image?.draw(in: CGRect.init(x: 0, y: 0, width: d.frame.width, height: d.frame.height))
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(!self.isDrawing){
        if let touch = touches.first{
            print(touch.view)
            if let d = ImageEdit {
                let currentCoordinate = touch.preciseLocation(in: d)
                UIGraphicsBeginImageContext(d.frame.size)
                d.image?.draw(in: CGRect.init(x: 0, y: 0, width: d.frame.width, height: d.frame.height))
                UIGraphicsGetCurrentContext()?.move(to: finalPoint)
                UIGraphicsGetCurrentContext()?.addLine(to: currentCoordinate)
                UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.round)
                UIGraphicsGetCurrentContext()?.setLineWidth(lineWidth)
                UIGraphicsGetCurrentContext()?.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
                UIGraphicsGetCurrentContext()?.strokePath()
                d.image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
        }
        }
    }
    
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
            let imageData = UIImageJPEGRepresentation(image, 1)
            let contextManaged = self.getContext()
            let a = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: contextManaged) as! Photo
            a.photo_data = imageData as NSData?
            do {
                try contextManaged.save()
            } catch{
                
            }
            //print(a.value(forKey: "photo_id"))
        }
        self.pictureid += 1
        self.save.isHidden = true
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "haha"{
            let testfetch = segue.destination as! Testcontroller
            
            //previewController.capturedPhoto = self.ImageCaptured
        }
    }
    

}
