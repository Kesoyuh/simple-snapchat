//
//  MapViewController.swift
//  simple-snapchat
//
//  Created by Helen on 10/10/2016.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
import GoogleMaps


class MapViewController: UIViewController {

    let getCurrentLocationBtn : UIButton = {
        let btn = UIButton()
        btn.titleLabel?.text = "My Location"
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    lazy var buttonsContainerView : UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x:0, y:0, width: self.view.frame.width, height: 80)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.black
        
        //Add get current location button
        containerView.addSubview(self.getCurrentLocationBtn)
        self.getCurrentLocationBtn.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        self.getCurrentLocationBtn.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8).isActive = true
 
        return containerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(closeMap))
        self.view.addSubview(buttonsContainerView)
        buttonsContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView

       
        
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

}
