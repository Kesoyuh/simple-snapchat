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

class PreviewController: UIViewController, UIPickerViewDataSource ,UIPickerViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate {
    
    /**
     The outlet of the image to be edited.
     */
    @IBOutlet weak var ImageEdit: UIImageView!
    
    /**
     The outlet of cancle editing image button.
     */
    @IBOutlet weak var CancleButton: UIButton!
    
    /**
     The outlet of save editing image button.
     */
    @IBOutlet weak var save: UIButton!
    
    /**
     The outlet of the text on image view.
     */
    @IBOutlet weak var text_on_image: UITextView!
    
    /**
     The outlet of the button to control displaying the text view.
     */
    @IBOutlet weak var Image_Text: UIButton!
    /**
     The outlet of the button to control drawing function.
     */
    @IBOutlet weak var Draw: UIButton!
    /**
     The outlet of the button to control displaying picker view.
     */
    @IBAction func selectDuration(_ sender: AnyObject) {
        self.DurationPick.isHidden = false
    }
    /**
     The outlet of the label to display emoji.
     */
    @IBOutlet weak var test: UILabel!
    
    /**
     The outlet of the picker view for selecting timer.
     */
    @IBOutlet weak var DurationPick: UIPickerView!
    
    /**
     The action button to quit preview view.
     */
    @IBAction func quit(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    /**
     The action button save the image into snaps and server.
     */
    @IBAction func SaveButton(_ sender: UIButton) {
        self.SaveImage()
        saveToFirebase()
    }
    /**
     The action button to send image to friend and server.
     */
    @IBAction func Sendtotest(_ sender: UIButton) {
        let image_original = self.captureScreen()
        let image_sending = self.ResizeImage(image: image_original, targetSize: CGSize.init(width:305.0,height:600.0))
        let sendtocontroller = SendToController()
        let sending_image = SendingPhoto()
        sending_image.image = image_sending
        sending_image.timer = self.pic_duaration
        sendtocontroller.photos.append(sending_image)
        
        let navController = UINavigationController(rootViewController: sendtocontroller)
        present(navController, animated: true, completion: nil)
    }
    /**
     The action button to realise controlling drawing on the image.
     */
    @IBAction func enable_draw(_ sender: UIButton) {
        
        if enabledrawing == true {
            enabledrawing = false
            self.ImageEdit.isUserInteractionEnabled = true
        }else {
            enabledrawing = true
            self.ImageEdit.isUserInteractionEnabled = false
        }
    }
    
    /**
     The action button to attach text on image.
     */
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
    
    /**
     The outlet of the collection view to show all the emojis.
     */
    @IBOutlet weak var allEmoji: UICollectionView!
    
    /**
     The action button to control displaying the collection view.
     */
    @IBAction func showStickers(_ sender: UIButton) {
        if enableemoji == true {
            enableemoji = false
            self.allEmoji.isHidden = false
        }else{
            enableemoji = true
            self.allEmoji.isHidden = true
        }
        
    }
    /**
     The outlet of the constraints of the text view.
     */
    @IBOutlet weak var TextX: NSLayoutConstraint!
    @IBOutlet weak var TextY: NSLayoutConstraint!
    
    /**
     The action gesture to realise draging the emoji on the picture.
     */
    @IBAction func Emoji_drag(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        sender.view?.center = CGPoint(x:sender.view!.center.x+translation.x, y:sender.view!.center.y+translation.y)
        sender.setTranslation(CGPoint.init(x: 0.0, y: 0.0), in: self.view)

    }
    
    /**
     The action gesture to realise draging the text on the picture.
     */
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
    var lebel :UILabel!
    var lebel_test :UILabel!
    
    var isDrawing : Bool! = false
    var enabledrawing : Bool! = true
    var enabletexting : Bool! = true
    var enableemoji :Bool! = true
    var finalPoint: CGPoint!
    var lineWidth: CGFloat = 4.0
    
    let red: CGFloat = 255.0/255.0
    let green: CGFloat = 0.0/255.0
    let blue: CGFloat = 0.0/255.0
    let Indentifier = "sticker"
    var emojiList: [String] = []
    var LabelList: [UILabel] = []
    var lastRotation = CGFloat()


    override func viewDidLoad() {
        super.viewDidLoad()
        DurationPick.delegate = self
        ImageEdit.image = capturedPhoto
        self.DurationPick.isHidden = true
        self.text_on_image.isHidden = true
        self.allEmoji.isHidden = true
        self.test.isHidden = true
        self.initEmoji()

    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ImageEdit.image = capturedPhoto
        

    }
    /**
     The method to save image to server.
     */
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
        let image_original = self.captureScreen()
        let image_upload = self.ResizeImage(image: image_original, targetSize: CGSize.init(width:304,height:604))
        let uploadData = UIImagePNGRepresentation(image_upload)
        
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
    
    /**
     The method to realise drawing on image.
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isDrawing = false
        self.DurationPick.isHidden = true
        self.allEmoji.isHidden = true
        self.enableemoji = true
        
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
    
    /**
     The method based on picker view delegate.
     */
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
    
    /**
     The method to save image to core data.
     */
    func SaveImage(){
        let saveQueue = DispatchQueue(label: "saveQueue",attributes: .concurrent)
        saveQueue.async {
            let image_original = self.captureScreen()
            let image_sending = self.ResizeImage(image: image_original, targetSize: CGSize.init(width:375.0,height:604.0))
            let imageData = UIImageJPEGRepresentation(image_sending, 1)
            let contextManaged = self.getContext()
            let a = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: contextManaged) as! Photo
            a.photo_data = imageData as NSData?
            a.timer = Int64(self.pic_duaration)
            a.user_id = FIRAuth.auth()?.currentUser?.uid
            print(a.user_id)
            do {
                try contextManaged.save()
            } catch{
                
            }
        }
        self.pictureid += 1
        self.save.isHidden = true
    }
    
    /**
     The method to resize image.
     */
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
    
    /**
     The method to realise the final image.
     */
    func captureScreen() -> UIImage {
        self.ImageEdit.addSubview(self.text_on_image)
        self.ImageEdit.addSubview(self.test)
        UIGraphicsBeginImageContextWithOptions(self.ImageEdit.bounds.size, false,0.0);
        let context = UIGraphicsGetCurrentContext();
        self.ImageEdit.layer.render(in: context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    /**
     The method based on the collectionview delegate.
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.emojiList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Indentifier, for: indexPath as IndexPath) as! StickerCell
        cell.emojilabel.text = self.emojiList[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("You have selected cell #\(indexPath.item)")
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let c:StickerCell = collectionView.cellForItem(at: indexPath) as! StickerCell
        self.test.text = c.emojilabel.text
        self.test.isHidden = false
        self.allEmoji.isHidden = true
        self.enableemoji = true
    }
    
    /**
     The method translate emoji unicode into string.
     */
    func initEmoji(){
        for c in 0x1F601...0x1F64F{
            self.emojiList.append(String(describing: UnicodeScalar(c)!))
        }
    }
    
}
