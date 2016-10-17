//
//  NewMessageTableViewController.swift
//  simple-snapchat
//
//  Created by Helen on 27/09/2016.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class ChatLogController: UICollectionViewController, UITextFieldDelegate ,UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    let cellID = "cellID"
    var messages = [Message]()
    
    // This uid is the partner id
    var partnerId: String?{
        didSet{
            let ref = FIRDatabase.database().reference().child("users").child(partnerId!)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                 let user = User()
                    user.setValuesForKeys(dictionary)
                    user.id = self.partnerId
                    self.navigationItem.title = user.name
                }
                }, withCancel: nil)
        }
    }
    
    func observeMessages(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let pid = partnerId else {
            return
        }
        let userMsgRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(pid)
        userMsgRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messageRef = FIRDatabase.database().reference().child("messages").child(messageId)
            
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else{return}
                let msg = Message(dictionary: dictionary)
                msg.messageID = snapshot.key
                print(snapshot.key)
                self.messages.append(msg)
                
                DispatchQueue.global().async {
                    
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                        //scroll to the last index
                        self.delay(1){
                            let count = self.messages.count - 1
                            let indexPath = NSIndexPath(item: count, section: 0)
                            self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)

                        }
                    }
                }
                }, withCancel: nil)
            
            }, withCancel: nil)
        

    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    let sendButton:UIButton = {
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(UIColor(red: 102, green: 178, blue: 255), for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        return sendButton
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Add top padding for collections
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(MessageCell.self, forCellWithReuseIdentifier: cellID)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.keyboardDismissMode = .interactive
        observeMessages()
        
        setupKeyboardObservers()
        
    }
    
    
    /*
       
            Add the animation for intext container and keyboard
     
     */
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    lazy var inputContainerView: UIView = {
    
        let containerView = UIView()
        containerView.frame = CGRect(x:0, y:0, width: self.view.frame.width, height: 80)
        containerView.backgroundColor = UIColor.white

        
        //-----------------------------------Add input textfield--------------------------------
        containerView.addSubview(self.inputTextField)
        //x,y,w,h constraint anchors for input textfield
        self.inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        self.inputTextField.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 8).isActive = true
        self.inputTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //-------------------Add a line separating input container and messages view --------------
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(red:220, green: 220, blue: 255)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        //x,y,w,h constraint anchors for separatorLine
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // Calculate the space between icons
        let space = (self.view.frame.width - 16 - 33*5)/4
        
        //-----------------------------------Add upload image icon--------------------------------

        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "chat_image")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(uploadImageView)
        
        let uploadTap = UITapGestureRecognizer(target: self, action: #selector(handleUploadTap))
        uploadImageView.addGestureRecognizer(uploadTap)
        uploadImageView.isUserInteractionEnabled = true
        
        uploadImageView.widthAnchor.constraint(equalToConstant: 33).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 33).isActive = true
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        uploadImageView.topAnchor.constraint(equalTo: self.inputTextField.bottomAnchor, constant: -8).isActive = true
        
        
        //-----------------------------------Add voice call icon--------------------------------
        let callView = UIImageView()
        callView.image = UIImage(named: "chat_call")
        containerView.addSubview(callView)
        callView.translatesAutoresizingMaskIntoConstraints = false
        callView.widthAnchor.constraint(equalToConstant: 33).isActive = true
        callView.heightAnchor.constraint(equalToConstant: 33).isActive = true
        callView.topAnchor.constraint(equalTo: self.inputTextField.bottomAnchor, constant: -8).isActive = true
        callView.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: space).isActive = true
        
        
        //-----------------------------------Add camera icon--------------------------------

        let cameraView = UIImageView()
        cameraView.image = UIImage(named: "chat_camera")
        containerView.addSubview(cameraView)
        cameraView.widthAnchor.constraint(equalToConstant: 33)
        cameraView.heightAnchor.constraint(equalToConstant: 33)
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        cameraView.widthAnchor.constraint(equalToConstant: 33).isActive = true
        cameraView.heightAnchor.constraint(equalToConstant: 33).isActive = true
        cameraView.topAnchor.constraint(equalTo: self.inputTextField.bottomAnchor, constant: -8).isActive = true
        cameraView.leftAnchor.constraint(equalTo: callView.rightAnchor, constant: space).isActive = true
        
        let cameraTap = UITapGestureRecognizer(target: self, action: #selector(openCamera))
        cameraView.addGestureRecognizer(cameraTap)
        cameraView.isUserInteractionEnabled = true

        

        //-----------------------------------Add video call icon--------------------------------
        let videoView = UIImageView()
        videoView.image = UIImage(named: "chat_video")
        containerView.addSubview(videoView)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.widthAnchor.constraint(equalToConstant: 33).isActive = true
        videoView.heightAnchor.constraint(equalToConstant: 33).isActive = true
        videoView.topAnchor.constraint(equalTo: self.inputTextField.bottomAnchor, constant: -8).isActive = true
        videoView.leftAnchor.constraint(equalTo: cameraView.rightAnchor, constant: space).isActive = true
        
        //-----------------------------------Add location icon--------------------------------
        let locationView = UIImageView()
        locationView.image = UIImage(named: "chat_location")
        containerView.addSubview(locationView)
        
        //Integrate map
        let mapTap = UITapGestureRecognizer(target: self, action: #selector(openMap))
        locationView.addGestureRecognizer(mapTap)
        locationView.isUserInteractionEnabled = true
        
        
        locationView.translatesAutoresizingMaskIntoConstraints = false
        locationView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        locationView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        locationView.topAnchor.constraint(equalTo: self.inputTextField.bottomAnchor, constant: -8).isActive = true
        locationView.leftAnchor.constraint(equalTo: videoView.rightAnchor, constant: space).isActive = true
 
        
        return containerView
    }()
    
    override var inputAccessoryView: UIView?{
        get{
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
    
        get{
            return true
        }
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let pid = partnerId else {
            return
        }
        let userMsgRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(pid)
        userMsgRef.removeValue { (error, FIRDatabaseReference) in
            print("delete all messages for ", uid, "'s child ", pid)
            let partnerMsgRef = FIRDatabase.database().reference().child("user-messages").child(pid).child(uid)
            partnerMsgRef.removeValue(completionBlock: { (eoor, FIRDatabaseReference) in
                print("delete all messages for ", pid, "'s child ", uid)
            })
        }
    }
    
    func setupKeyboardObservers(){
         NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
    }
    
    func handleKeyboardDidShow(notification: Notification){
        if messages.count > 0{
            let index = messages.count - 1
            let indexPath = NSIndexPath(item: index, section: 0)
            self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
        }

    }
    
    func handleKeyboardWillShow(notification: Notification){
        //get keyboard height
        let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let height = keyboardFrame.cgRectValue.height
        
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let duration = keyboardDuration.doubleValue
        
        containerViewBottomAnchor?.constant = -height
        
        UIView.animate(withDuration: duration) { 
            self.view.layoutIfNeeded()
        }
    }
    
    func handleKeyboardWillHide(notification: Notification){
        
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let duration = keyboardDuration.doubleValue
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! MessageCell
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        cell.chatLogController = self
        setupCell(cell: cell, message: message, index: indexPath.row)
        
        // Modify the bubble size based on content size
        // Hide the text view if that is an imgae because text view is on the top of the image view
        if let text = message.text{
            print("----------This is a text message!------------------", message)
          cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            cell.textView.isHidden = false
        }else if message.latitude != nil {
            print("----------This is a location message!------------------")
            cell.imageType = 1
            cell.lat = message.latitude
            cell.lng = message.longitude
            cell.bubbleWidthAnchor?.constant = 50
            cell.textView.isHidden = true
        }else if message.timer != nil {
            print("----------This is a timer message!------------------", message.timer)
            cell.imageType = 2
            cell.timer = message.timer
            cell.messageID = message.messageID
            cell.index = indexPath.row
            cell.openTimes = 0
            cell.imageURL = message.imageUrl
            cell.bubbleWidthAnchor?.constant = 80
            cell.textView.isHidden = true
        
        }else if message.imageUrl != nil {
            print("----------This is a image message!------------------")
            cell.imageType = 0
            cell.bubbleWidthAnchor?.constant = 200
            //If the text view is not hidden, tap gesture recognizer won't work
            cell.textView.isHidden = true
        }

        return cell
    }
    
    private func setupCell(cell: MessageCell, message: Message, index: Int){
        
        if message.timer != nil{
            print("I want to show a timer icon here")
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
            cell.messageImageView.image = UIImage(named:"chat_receive")
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
            
            
        } else if let messageImageUrl = message.imageUrl {
            
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
            
        }else if message.latitude != nil{
            
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
            cell.messageImageView.image = UIImage(named:"chat_location")
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        
        }else{
            
            cell.messageImageView.isHidden = true
          
        }
        
        // Incoming and outgoing messages
        if message.fromID == FIRAuth.auth()?.currentUser?.uid {
            // outgoing blue bubble
            cell.bubbleView.backgroundColor = MessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        }else{
            // incoming gray bubble
            cell.bubbleView.backgroundColor = MessageCell.grayColor
            cell.textView.textColor = UIColor.black
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //Change the cell height according to the text length
        var height: CGFloat = 80
        let message = messages[indexPath.item]
        if let text = message.text{
            height = estimateFrameForText(text: text).height + 20
        }else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            
            height = CGFloat(200 * imageHeight / imageWidth)
        }else if (message.latitude != nil) {
            height = 50
        }
        return CGSize(width: view.frame.width, height: height)
    }
    
    // Get the rec size for input text
    private func estimateFrameForText(text: String) -> CGRect{
        // This width is equal to the width of bubble view
        let size = CGSize(width:200, height:1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
        
    }
    
    // Send button tapped function
    func handleSend(){
        self.inputTextField.endEditing(true)
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let fromID = FIRAuth.auth()!.currentUser!.uid
        let toID = partnerId!
        let timestamp = Int(NSDate().timeIntervalSince1970)
        let values = ["text": inputTextField.text!, "toID": toID, "fromID": fromID, "timestamp": timestamp] as [String : Any]
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error)
                return
            }
            //Update user-messages for both sender and receiver
            let senderMsgRef = FIRDatabase.database().reference().child("user-messages").child(fromID).child(toID)
            senderMsgRef.updateChildValues([childRef.key : 1])
            let receiverMsgRef = FIRDatabase.database().reference().child("user-messages").child(toID).child(fromID)
            receiverMsgRef.updateChildValues([childRef.key : 1])
            
            //Update friendship level for both sender and receiver
            let senderFriendLevel = FIRDatabase.database().reference().child("friendship-level").child(fromID)
            senderFriendLevel.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if var dictionary = snapshot.value as? [String: Int]{
                    // check if there is the child for toID
                    if let count = dictionary[toID] {
                        dictionary[toID] = count + 1
                    }else{
                        dictionary[toID] = 1
                    }
                    senderFriendLevel.updateChildValues(dictionary)
                    
                }else{
                    //There is no data, add the first one
                    let new = [toID : 1]
                    senderFriendLevel.updateChildValues(new)
                }
            })
            
            let receiverFriendLevel = FIRDatabase.database().reference().child("friendship-level").child(toID)
            receiverFriendLevel.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if var dictionary = snapshot.value as? [String: Int]{
                    // check if there is the child for toID
                    if let count = dictionary[fromID] {
                        dictionary[fromID] = count + 1
                    }else{
                        dictionary[fromID] = 1
                    }
                    receiverFriendLevel.updateChildValues(dictionary)
                    
                }else{
                    //There is no data, add the first one
                    let new = [fromID : 1]
                    receiverFriendLevel.updateChildValues(new)
                }
            })

        
            
    }
        
        self.inputTextField.text = nil
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }

    
    /*
     
            functions for icons
     
     */
    
    
    func handleUploadTap(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true,completion:nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        selectedImageFromPicker = info["UIImagePickerControllerOriginalImage"] as? UIImage
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorageUsingImage(image: selectedImage)
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage){
        let imageName = NSUUID().uuidString
        let ref = FIRStorage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.01){
            ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("Failed to upload image :", error)
                    return
                }
                if let imageUrl = metadata?.downloadURL()?.absoluteString{
                    self.sendMessageWithImageUrl(imageUrl: imageUrl, image: image)
                }
            })
        }
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage){
        
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let fromID = FIRAuth.auth()!.currentUser!.uid
        let toID = partnerId!
        let timestamp = Int(NSDate().timeIntervalSince1970)
        let values = [ "toID": toID, "fromID": fromID, "timestamp": timestamp, "imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height] as [String : Any]
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error)
                return
            }
            //Update user-messages for both sender and receiver
            let senderMsgRef = FIRDatabase.database().reference().child("user-messages").child(fromID).child(toID)
            senderMsgRef.updateChildValues([childRef.key : 1])
            let receiverMsgRef = FIRDatabase.database().reference().child("user-messages").child(toID).child(fromID)
            receiverMsgRef.updateChildValues([childRef.key : 1])
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        dismiss(animated: true, completion: nil)
    }
    
    
    /*
        Handle image zoom in and zoom out
     */
    
    var startingFrame: CGRect?
    var blackBackgroundVBiew : UIView?
    func performZoomInForStartingImageView(startingImageView: UIImageView) {
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        if let keyWindow = UIApplication.shared.keyWindow{
            //Add black background
            blackBackgroundVBiew = UIView(frame: keyWindow.frame)
            blackBackgroundVBiew?.backgroundColor = UIColor.black
            blackBackgroundVBiew?.alpha = 0
            keyWindow.addSubview(blackBackgroundVBiew!)
            
            //Add the image and modify the size
            keyWindow.addSubview(zoomingImageView)
            zoomingImageView.image = startingImageView.image
            let h = (keyWindow.frame.width) * startingFrame!.height / (startingFrame!.width)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity:1, options: .curveEaseOut, animations: {
                self.blackBackgroundVBiew?.alpha = 1
                self.inputContainerView.alpha = 0
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: h)
                zoomingImageView.center = keyWindow.center
                
                }, completion: nil)}
    }
    
    func handleZoomOut(tapGesture: UITapGestureRecognizer){
        
        if let zoomOutImageView = tapGesture.view{
            //Ned to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity:1, options: .curveEaseOut, animations: {

                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundVBiew?.alpha = 0
                self.inputContainerView.alpha = 1
                }, completion: { (completed: Bool) in
                    zoomOutImageView.removeFromSuperview()
            
            })
        }
    }
    
    
    /*
        Handle Map
     */
    
    func openMap(){
        let mapController = MapViewController()
        mapController.fromID = FIRAuth.auth()!.currentUser!.uid
        mapController.toID = partnerId!
        let navController = UINavigationController(rootViewController: mapController)
        present(navController, animated:true, completion:nil)

    
    }
    
    func openMapWithLocation(location : CLLocationCoordinate2D){
        let mapController = MapViewController()
        mapController.fromID = FIRAuth.auth()!.currentUser!.uid
        mapController.toID = partnerId!
        mapController.partnerLocation = location
        let navController = UINavigationController(rootViewController: mapController)
        present(navController, animated:true, completion:nil)
    }
    
    func handleShareLocation(lat: String, lng: String) {
        let location = CLLocationCoordinate2D(latitude: (lat as NSString).doubleValue, longitude: (lng as NSString).doubleValue )
        openMapWithLocation(location: location)

    }
    
    
    /*
     
     Handle timer and view constraints
     
     */
    
    func handleTimer(time: Int!, imageURL: String!, openTimes: Int!, messageID: String!, index: Int!){

        if openTimes == 1 {
            let newImageView = ImageWithTimerViewController()
            newImageView.timer = time
            newImageView.imgUrl = imageURL
            newImageView.chat = self
            let navController = UINavigationController(rootViewController: newImageView)
            present(navController, animated:true, completion:nil)

        } else if openTimes == 2 {
            let newImageView = ImageWithTimerViewController()
            newImageView.timer = time
            newImageView.imgUrl = imageURL
            newImageView.chat = self
            let navController = UINavigationController(rootViewController: newImageView)
            present(navController, animated:true, completion:nil)
            
            //Delete from database
            guard let uid = FIRAuth.auth()?.currentUser?.uid, let pid = partnerId else {
                return
            }
            print("That image should be deleted!", messageID)
            let myMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(pid).child(messageID)
            myMessagesRef.removeValue(completionBlock: { (error, FIRDatabaseReference) in
                print("Delete it from user-messages", uid,"'s child", pid)
                let partnerMessageRef = FIRDatabase.database().reference().child("user-messages").child(pid).child(uid).child(messageID)
                partnerMessageRef.removeValue(completionBlock: { (error, FIRDatabaseReference) in
                    print("Delete it from user-messages", pid,"'s child", uid)
                    DispatchQueue.global().async {
                        DispatchQueue.main.async {
                            self.messages.remove(at: index)
                            self.collectionView?.reloadData()
                            print("That image should be deleted!", messageID)
                        }
                    }
                })
            })
        }
        // TODO: Open the image and add timer
    }
    
    func openCamera(){
        let scrollView = self.navigationController?.view.superview as? UIScrollView
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            scrollView!.contentOffset.x = self.view.frame.width
            }, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }

}




