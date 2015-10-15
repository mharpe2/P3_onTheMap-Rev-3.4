
//
//  InformationPostingView.swift
//  P3_onTheMap
//
//  Created by Michael Harper on 9/11/15.
//  Copyright (c) 2015 hxx. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class InformationPostingVC: UIViewController {
    
    // Outlets
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var findOnMapButton: UIButton!
    @IBOutlet weak var browseButton: UIButton!
    
    
    // Map Variables
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    var udacity: UdacityClient! // grab our clients
    var parse: ParseMngr!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        udacity = UdacityClient.sharedInstance()
        parse = ParseMngr.sharedInstance()
        
    }
    
    func searchForLocationDisplayOnMap(completionHandler: (success: Bool, errorString: String?) -> Void ) {
        
        // setup activity view
        let activityViewIndicator : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
        activityViewIndicator.center = self.view.center
        activityViewIndicator.hidesWhenStopped = true
        activityViewIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        
        // start spinning activityView
        view.addSubview(activityViewIndicator)
        activityViewIndicator.startAnimating()
        view.alpha = 0.5
        
        
        // if there are existing annotaions, remove them
        if !(self.mapView.annotations.isEmpty) {
            
            //remove all annotations before adding any
            let oldAnnotations = self.mapView.annotations
            self.mapView.removeAnnotations(oldAnnotations)
        }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationTextField.text!, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                displayError(self, errorString: error!.localizedDescription)
                activityViewIndicator.stopAnimating()
                self.view.alpha = 1.0
                completionHandler(success: false, errorString: "GeocodeAddressString Failed: \(error?.localizedDescription)" )
                return
            } else if let placemark = placemarks?[0] {
                
                let coordinates = placemark.location!.coordinate
                
                self.pointAnnotation = MKPointAnnotation()
                self.pointAnnotation.title = self.locationTextField.text
                self.pointAnnotation.coordinate =  coordinates
                
                self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
                self.mapView.centerCoordinate = self.pointAnnotation.coordinate
                self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
                
                activityViewIndicator.stopAnimating()
                self.view.alpha = 1.0
                completionHandler(success: true, errorString: nil)
                return
            }
        })
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        
        // retrieve key, first name, last name from udacity
        var student: [String:AnyObject] = [:]
        udacity.getUserInfo()
        
        // UIControlEvents.TouchUpInside
        
        // Alternative to  commented code
        //findOnMapButton.sendActionsForControlEvents( UIControlEvents.TouchUpInside )
        
        
        // update coords
        
        
        self.searchForLocationDisplayOnMap( {(success, error) -> Void in
            if success {
                print("attempt point")
                if let point = self.pointAnnotation {
                    student["longitude"] = point.coordinate.longitude // point would be nil, if not in closure
                    student["latitude"] = point.coordinate.latitude
                }
                
            }else {
                displayError(self, errorString: "Location data invalid, check your address")
                return
            }
        //})
        
        
        // gather user data from view and udacity singleton
        student["mapString"] = self.locationTextField.text!  //from view
        student["mediaURL"] = self.linkTextField.text!        //from view
        student["firstName"] = self.udacity.firstName
        student["lastName"] = self.udacity.lastName
        student["uniqueKey"] = self.udacity.userID
        
        if let point = self.pointAnnotation {
            student["longitude"] = point.coordinate.longitude // point would be nil, if not in closure
            student["latitude"] = point.coordinate.latitude
        } else {
            displayError(self, errorString: "Location data invalid, longitude/latitude bad")
            return
        }
            
        
        
        
        self.parse.postLocation(student, completionHandler: {(success, errorString) -> Void in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            } else {
                displayError(self, errorString: errorString)
            }
        })
        })
        
    }
    
    @IBAction func browseButtonPressed(sender: AnyObject) {
        
        // Private function
        // Tests URL first, if it thinks it can be opened then it is attemped
        func openAppLink(link: String) -> Bool {
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: link)!) {
                let app = UIApplication.sharedApplication()
                app.openURL(NSURL(string: linkTextField.text!)!)
                return true
                
            }
            return false
        }
        
        let originalString = linkTextField.text!
        
        if !openAppLink(originalString)
        {
            // check user input string for https:// or http://
            // if there is none attempt to add it to the string
            // app.open will fail if there is
            if !originalString.hasPrefix("https://")  ||
                !originalString.hasPrefix("http://") {
                    
                    if (openAppLink("http://" + originalString ) ) {
                        linkTextField.text = "http://" + originalString
                        openAppLink(linkTextField.text!)
                        return
                        
                        // if http does not work try https
                    } else if (openAppLink("https://" + originalString) ) {
                        linkTextField.text = "https://" + originalString
                        openAppLink(linkTextField.text!)
                        return
                    }
            }
            
        } else if (openAppLink(linkTextField.text!) ){
            return
        }
        else {
            // this may never be executed
            // canOpen doesn't care about the link being valid
            displayError(self, errorString: "The link does appear to be valid")
            return
        }
        
    }
    
    @IBAction func findOnMapButtonPressed(sender: AnyObject) {
        
        searchForLocationDisplayOnMap( {(success, error) in
            if success {
                //Code
            } else {
                displayError(self, errorString: error)
            }
        } )
    }
}

