//
//  TopViewController.swift
//  snapchat
//
//  Created by Jeffrey on 21/09/2016.
//  Copyright © 2016 Boqin Hu. All rights reserved.
//

import UIKit
import Parse
import Firebase

class TopViewController: UIViewController {
    

    
    let QRCode: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.black
        return imageView
    }()
    
    let nameLabel : UILabel = {
        let name = UILabel()
        name.textColor = UIColor.white
        name.font = UIFont.boldSystemFont(ofSize: 22)
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(QRCode)
        self.view.addSubview(nameLabel)
        

        // Constraints for QR code
        QRCode.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100).isActive = true
        QRCode.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        QRCode.widthAnchor.constraint(equalToConstant: 200).isActive = true
        QRCode.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        // Constraints for name label
        nameLabel.topAnchor.constraint(equalTo: QRCode.bottomAnchor, constant: 20).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        
        delay(2, closure: {
        self.loadQRCode()
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadQRCode()
    }
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    func loadQRCode(){
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        if uid != nil {
            print("current user is ", uid)
            if let code = generateQRCode(from: uid!){
                DispatchQueue.global().async {
                    DispatchQueue.main.async {
                        self.QRCode.image = code
                    }
                }
            }
            
            let nameRef = FIRDatabase.database().reference().child("users").child(uid!)
            nameRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    DispatchQueue.global().async {
                        DispatchQueue.main.async {
                             self.nameLabel.text = dictionary["name"] as? String
                        }
                    }

                }
            })
        }else {
            
            print("You need to login first!")
            //let loginRegisterController = LoginRegisterController()
            //present(loginRegisterController, animated: true, completion: nil)
            
        }
    }
    
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(_ sender: UIButton) {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let error{
            print(error)
        }
        let loginRegisterController = LoginRegisterController()
        let scrollView = self.view.superview as? UIScrollView
        scrollView!.contentOffset.y = view.bounds.height
        
        present(loginRegisterController, animated: true, completion: nil)
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.applying(transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
