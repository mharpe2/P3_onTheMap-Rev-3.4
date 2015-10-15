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
        
        refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshButtonPressed:")
        
        pinImage = UIImage(named: "pin.pdf")!
        pinButton = UIBarButtonItem(image: pinImage, style: UIBarButtonItemStyle.Plain, target: self, action: "pinButtonPressed:")
        
        let rightButtons = [refreshButton!, pinButton!]
        self.navigationItem.rightBarButtonItems = rightButtons
        
        mapView.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        parseMngr.updateStudentInformation { (success, errorString) -> Void in
            if success {
                    dispatch_async(dispatch_get_main_queue()) {
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
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView! {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
            
            //MARK: New Feature
            //change current users pin  Green on map
            if parseMngr.currentUserInformation != nil {
                if (pinView?.annotation?.title)! == ("\(parseMngr.currentUserInformation.firstName) \(parseMngr.currentUserInformation.lastName)") {
                    pinView?.pinColor = .Green
                    
                } else {
                    pinView?.pinColor = .Red
                }
            }
        }
        return pinView
    }
    
    // delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation!.subtitle!!)!)
        }
    }
    
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        UdacityClient.sharedInstance().logout()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func refreshButtonPressed(sender: UIButton) {
        
        refreshButton.enabled = false
        
        // remove all annotations from the map
        let annotations = self.mapView.annotations
        self.mapView.removeAnnotations( annotations )
        
        parseMngr.updateStudentInformation { (success, errorString) -> Void in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    self.doMapStuff()
                    self.refreshButton.enabled = true
                }
            } else {
                displayError(self, errorString: String("Failed to refresh " + errorString!) )
                print(errorString)
            }
        }
    }
    
    func pinButtonPressed(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingController") 
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
}