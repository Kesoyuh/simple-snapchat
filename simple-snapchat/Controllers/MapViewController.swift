//
//  MapViewController.swift
//  simple-snapchat
//
//  Created by Helen on 10/10/2016.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Firebase


class MapViewController: UIViewController, CLLocationManagerDelegate , MKMapViewDelegate{
    
    let locationManager = CLLocationManager()
    var location = CLLocation()
    var mapView = MKMapView()
    var fromID : String?
    var toID : String?
    var partnerLocation = CLLocationCoordinate2D()
    
    lazy var getCurrentLocationBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("Share", for: .normal)
        btn.backgroundColor = UIColor.white
        btn.alpha = 0.7
        btn.layer.cornerRadius = CGFloat(10.0)
        btn.setTitleColor(UIColor.darkGray, for: UIControlState())
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return btn
    }()
    

       override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(closeMap))
        view = mapView
        
        // Add get my location button
        mapView.addSubview(getCurrentLocationBtn)
        self.getCurrentLocationBtn.rightAnchor.constraint(equalTo: mapView.rightAnchor,constant: -12).isActive = true
        self.getCurrentLocationBtn.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -8).isActive = true
        self.getCurrentLocationBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.getCurrentLocationBtn.widthAnchor.constraint(equalToConstant: 110).isActive = true
        view = mapView
        
        
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
        
        if partnerLocation != nil {
            let annotation = MKPointAnnotation()
            annotation.coordinate   = partnerLocation
            annotation.title        = "Chat partner"
            
            mapView.addAnnotation(annotation)

        }
        
  
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Errors: ", error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last!
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta:1, longitudeDelta: 1))
        self.mapView.setRegion(region, animated: true)
        //self.locationManager.stopUpdatingLocation()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closeMap(){
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func buttonTapped(){
        print("My location is", location.coordinate)
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        let lat : String = location.coordinate.latitude.description
        let lng : String = location.coordinate.longitude.description

        
        let timestamp = Int(NSDate().timeIntervalSince1970)
        let values = ["latitude": lat , "longitude": lng,"toID": self.toID!, "fromID": self.fromID!, "timestamp": timestamp] as [String : Any]
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error)
                return
            }
            //Update user-messages for both sender and receiver
            let senderMsgRef = FIRDatabase.database().reference().child("user-messages").child(self.fromID!).child(self.toID!)
            senderMsgRef.updateChildValues([childRef.key : 1])
            let receiverMsgRef = FIRDatabase.database().reference().child("user-messages").child(self.toID!).child(self.fromID!)
            receiverMsgRef.updateChildValues([childRef.key : 1])
        }
        closeMap()

    }
    
  
}


