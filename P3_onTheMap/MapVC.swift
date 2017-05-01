//
//  MapVC.swift
//  P3_onTheMap
//
//  Created by Michael Harper on 8/17/15.
//  Copyright (c) 2015 hxx. All rights reserved.
//

import UIKit
import MapKit
import FBSDKLoginKit


class MapVC: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    var refreshButton: UIBarButtonItem! = nil
    var pinButton: UIBarButtonItem! = nil
    var pinImage: UIImage! = nil
    
    var parseMngr: ParseMngr!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parseMngr = ParseMngr.sharedInstance()
        
        //Mark: Custom Navigation buttons
        
        refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(MapVC.refreshButtonPressed(_:)))
        
        pinImage = UIImage(named: "pin.pdf")!
        pinButton = UIBarButtonItem(image: pinImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(MapVC.pinButtonPressed(_:)))
        
        let rightButtons = [refreshButton!, pinButton!]
        self.navigationItem.rightBarButtonItems = rightButtons
        
        mapView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        parseMngr.updateStudentInformation { (success, errorString) -> Void in
            if success {
                    DispatchQueue.main.async {
                    self.doMapStuff()
                }
            } else {
                displayError(self, errorString: errorString)
            }
        }
    }
    
    func doMapStuff() {
        
        // remove all annotations from the map
        let oldAnnotations = self.mapView.annotations //as? [MKAnnotation]
        self.mapView.removeAnnotations( oldAnnotations )

        
        var annotations = [MKPointAnnotation]()
        for student in parseMngr.students {
            
            var coordinate: CLLocationCoordinate2D!
            let annotation = MKPointAnnotation()
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
            annotation.coordinate = coordinate
            annotation.title = "\(student.firstName) \(student.lastName)"
            annotation.subtitle = student.mediaURL
            annotations.append(annotation)
            
        }
        
        // When the array is complete, add the annotations to the map.
        self.mapView.addAnnotations(annotations)
        
    }
    
    // MARK: - MKMapViewDelegate
    
    // create a view with a "right callout accessory view". 
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView! {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
            
            //MARK: New Feature
            //change current users pin  Green on map
            if parseMngr.currentUserInformation != nil {
                if (pinView?.annotation?.title)! == ("\(parseMngr.currentUserInformation.firstName) \(parseMngr.currentUserInformation.lastName)") {
                    pinView?.pinColor = .green
                    
                } else {
                    pinView?.pinColor = .red
                }
            }
        }
        return pinView
    }
    
    // delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.shared
            guard let annotation = annotationView.annotation,
            let subtitle = annotation.subtitle, subtitle != "" else {
                return
            }
            app.openURL(URL(string: subtitle!)!)
        }
    }
    
    
    @IBAction func logoutButtonPressed(_ sender: AnyObject) {
        UdacityClient.sharedInstance().logout()
        self.dismiss(animated: true, completion: nil)
    }
    
    func refreshButtonPressed(_ sender: UIButton) {
        
        refreshButton.isEnabled = false
        
        // remove all annotations from the map
        let annotations = self.mapView.annotations
        self.mapView.removeAnnotations( annotations )
        
        parseMngr.updateStudentInformation { (success, errorString) -> Void in
            if success {
                DispatchQueue.main.async {
                    self.doMapStuff()
                    self.refreshButton.isEnabled = true
                }
            } else {
                displayError(self, errorString: String("Failed to refresh " + errorString!) )
                print(errorString)
            }
        }
    }
    
    func pinButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async(execute: {
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "InformationPostingController") 
            self.present(controller, animated: true, completion: nil)
        })
    }
}
