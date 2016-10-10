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


class MapViewController: UIViewController, CLLocationManagerDelegate , MKMapViewDelegate{
    
    let locationManager = CLLocationManager()
    var mapView = MKMapView()
    
    lazy var getCurrentLocationBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("My Location", for: .normal)
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
        
  
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Errors: ", error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta:1, longitudeDelta: 1))
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
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
    
    
    }

}


