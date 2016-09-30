//
//  PreviewController.swift
//  simple-snapchat
//
//  Created by Boqin Hu on 29/9/16.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
class PreviewViewController: UIViewController {
    
    @IBOutlet weak var CapturedPhotoView : UIImageView!
    
    @IBOutlet weak var CancleButton: UIButton!
    
    var capturedPhoto :UIImage!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        CapturedPhotoView.image = capturedPhoto
    }

}
