//
//  AppDelegate.swift
//  snapchat
//
//  Created by Boqin Hu on 27/07/2016.
//  Copyright © 2016 Boqin Hu. All rights reserved.
//

import UIKit
import Bolts
import Firebase
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "photoModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                
                fatalError("Unresolved error \(error), \(error)")
            }
        })
        return container
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool{
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let left = storyboard.instantiateViewController(withIdentifier: "left")
        let middle = storyboard.instantiateViewController(withIdentifier: "camera")
        let right = storyboard.instantiateViewController(withIdentifier: "right")
        let top = storyboard.instantiateViewController(withIdentifier: "top")
        let bottom = storyboard.instantiateViewController(withIdentifier: "bottom")
        
        let snapContainer = SnapContainerViewController.containerViewWith(left, middleVC: middle as! CameraViewController, rightVC: right as! UINavigationController, topVC: top, bottomVC: bottom)
        
        self.window?.rootViewController = snapContainer
        self.window?.makeKeyAndVisible()
        
        
        // Initialize Firebase
        FIRApp.configure()
        
        return true
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
}

