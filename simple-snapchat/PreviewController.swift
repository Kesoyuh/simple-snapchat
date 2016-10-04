//
//  PreviewController.swift
//  simple-snapchat
//
//  Created by Boqin Hu on 29/9/16.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
class PreviewController: UIViewController {
    
    
    @IBOutlet weak var ImageEdit: UIImageView!
    @IBOutlet weak var CancleButton: UIButton!
    
    @IBAction func quit(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    var capturedPhoto :UIImage!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ImageEdit.image = capturedPhoto

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ImageEdit.image = capturedPhoto

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ImageEdit.image = capturedPhoto
    }

}
