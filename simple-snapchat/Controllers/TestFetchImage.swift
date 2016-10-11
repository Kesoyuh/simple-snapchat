//
//  TestFetchImage.swift
//  simple-snapchat
//
//  Created by Boqin Hu on 10/10/16.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Testcontroller : UIViewController {
    
    @IBAction func change(_ sender: UIButton) {
    }
    @IBOutlet weak var test_image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getTranscroptios()
//        let fetchRequest: NSFetchRequest = Photo.fetchRequest()
//
//        let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { (asynchronousFetchResult) -> Void in
//            DispatchQueue.main.sync(execute: { () -> Void in
//                self.processAsynchronousFetchResult(asynchronousFetchResult: asynchronousFetchResult)
//            })
//        }
//        do {
//            // Execute Asynchronous Fetch Request
//            let asynchronousFetchResult = try self.getContext().execute(asynchronousFetchRequest)
//            print(asynchronousFetchResult)
//            
//        } catch {
//            let fetchError = error as NSError
//            print("\(fetchError), \(fetchError.userInfo)")
//        }
////        let asynchronoueFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest)
////        do {
////            let result = try self.getContext().execute(asynchronoueFetchRequest)
////            
////        }catch {
////            let fetchError = error as NSError
////            print("\(fetchError)")
////        }
//
    }
//    func processAsynchronousFetchResult(asynchronousFetchResult: NSAsynchronousFetchResult<Photo>) {
//        if let result = asynchronousFetchResult.finalResult {
////            // Update Items
////            items = result as! [NSManagedObject]
////
////            // Reload Table View
////            tableView.reloadData()
//            self.test_image.image = UIImage(data:result[1].photo_data as! Data,scale:1.0)
//        }
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        
    }
    
    func getTranscroptios(){
        let saveQueue = DispatchQueue(label: "saveQueue",attributes: .concurrent)
//        saveQueue.async {
//        var photos: Array<Photo> = []
//            let fetchRequest: NSFetchRequest = Photo.fetchRequest()
//            do {
//                let results = try self.getContext().fetch(fetchRequest)
////                for i in 0...results.count {
////                    let photo: Photo = Photo()
////                    photo.photo_data = results[i].photo_data
////                    photos.append(photo)
////                }
////                self.test_image.image = UIImage(data: photos[1].photo_data as! Data,scale:1.0)
//                let a: UIImage = UIImage(data: results[1].photo_data as! Data , scale: 1.0)!
//                
//                
//            } catch let error as NSError{
//                print("could not fetch \(error)")
//            }
        saveQueue.async {
            let fetchRequest: NSFetchRequest = Photo.fetchRequest()
            do {
                let results = try self.getContext().fetch(fetchRequest)
                print(results.count)
                let a: UIImage = UIImage(data: results[1].photo_data as! Data , scale: 1.0)!
                self.test_image.image = a

            }
             catch let error as NSError{
                print("could not fetch \(error)")

            }
        }
        
        
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
    
    
}
