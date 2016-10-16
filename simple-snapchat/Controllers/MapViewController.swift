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
    var partnerLocation = kCLLocationCoordinate2DInvalid
    
    lazy var myBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("Share my location", for: .normal)
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
        mapView.addSubview(myBtn)
        self.myBtn.rightAnchor.constraint(equalTo: mapView.rightAnchor,constant: -12).isActive = true
        self.myBtn.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -8).isActive = true
        self.myBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.myBtn.widthAnchor.constraint(equalToConstant: 200).isActive = true
        view = mapView
        
        
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true

        }
        
        if CLLocationCoordinate2DIsValid(partnerLocation) {
            print("Partner location is :",partnerLocation)
            //Add pin
            
            let annotation = MKPointAnnotation()
            annotation.coordinate   = partnerLocation
            annotation.title        = "Chat partner"
            
            mapView.addAnnotation(annotation)
            
            // Change Button
            myBtn.setTitle("Calculate Distance", for: .normal)

        }
        
       
    }

    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Errors: ", error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last!
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta:0.001, longitudeDelta: 0.001))
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

        if CLLocationCoordinate2DIsValid(partnerLocation){
            calculateDistance(source: location.coordinate, destination: partnerLocation)
        }else{
            shareLocation()
        }
    }
    
    func shareLocation(){
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
    
    
    func calculateDistance(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D){
        // Show Pin
        let annotation = MKPointAnnotation()
        annotation.coordinate   = source
        annotation.title        = "My location"
        mapView.addAnnotation(annotation)


        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            var shortestDistance : CLLocationDistance
            guard let unwrappedResponse = response else { return }
            shortestDistance = (unwrappedResponse.routes.first?.distance)!
            for route in unwrappedResponse.routes{
                    if route.distance < shortestDistance {
                        shortestDistance = route.distance
                    }
                
                self.mapView.add(route.polyline, level: MKOverlayLevel.aboveLabels)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect , animated: true)
                
            }
            
            let txt = "The distance between you two is \(shortestDistance) meters!"
            self.displayAlert(title: "Distance", message: txt)

        }
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)

        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 5
        return renderer
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }

}


