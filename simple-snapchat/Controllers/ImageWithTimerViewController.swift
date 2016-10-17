//
//  ImageWithTimerViewController.swift
//  simple-snapchat
//
//  Created by Helen on 14/10/16.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
import Firebase

class ImageWithTimerViewController: UIViewController {

    var timer : Int?
    var imgUrl : String?
    var chat = ChatLogController()
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        imageView.backgroundColor = UIColor.black
        return imageView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target:self, action: #selector(handleCancel))
        var title = "You can view for "
        title.append(String(timer!))
        title.append(" seconds")
        navigationItem.title = title
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor(red: 102, green: 178, blue: 255)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor(red: 102, green: 178, blue: 255)]
        navigationController?.navigationBar.isHidden = false
        view.addSubview(imageView)
        // Add constraints
        imageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100).isActive = true
        imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true

        imageView.loadImageUsingCacheWithUrlString(urlString: imgUrl!)
        
        let delayTime = Double(timer!)
        delay(delayTime){
            self.handleCancel()
        }
    }

    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    func handleCancel(){
        self.dismiss(animated: true) {
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
