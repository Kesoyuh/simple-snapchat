//
//  Extensions.swift
//  simple-snapchat
//
//  Created by Helen on 1/10/2016.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
import Firebase

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView{

    func loadImageUsingCacheWithUrlString(urlString: String){
    
        self.image = nil
        
        //Check cache for iumage first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        //Otherwise fire off a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler:{
            (data, response, error) in
            if error != nil {
             print("Download image process failed :", error)
            return
            }
            
            
            DispatchQueue.global().async {
                
                DispatchQueue.main.async {
                    if let downloadedImage = UIImage(data: data!) {
                        imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                        self.image = downloadedImage
                    }
                }
            }

            
        }).resume()
    }

}
