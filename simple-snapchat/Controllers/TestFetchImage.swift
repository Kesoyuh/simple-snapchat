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
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var test_image: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        getTranscroptios()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        
    }
    
    func getTranscroptios(){
        let fetchQueue = DispatchQueue.main
        fetchQueue.async {
            let fetchRequest: NSFetchRequest = Photo.fetchRequest()
            do {
                let results = try self.getContext().fetch(fetchRequest)
                let a: UIImage = UIImage(data: results.last!.photo_data as! Data , scale: 1)!
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
