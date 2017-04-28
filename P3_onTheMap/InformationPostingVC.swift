
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
    
    func searchForLocationDisplayOnMap(_ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void ) {
        
        // setup activity view
        let activityViewIndicator : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 50, height: 50)) as UIActivityIndicatorView
        activityViewIndicator.center = self.view.center
        activityViewIndicator.hidesWhenStopped = true
        activityViewIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
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
                completionHandler(false, "GeocodeAddressString Failed: \(error?.localizedDescription)" )
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
                completionHandler(true, nil)
                return
            }
        })
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
        
        // retrieve key, first name, last name from udacity
        var student: [String:AnyObject] = [:]
        udacity.getUserInfo()
        
        // update coords.  Use closure
        self.searchForLocationDisplayOnMap( {(success, error) -> Void in
            if success {
                print("attempt point")
                if let point = self.pointAnnotation {
                    student["longitude"] = point.coordinate.longitude as AnyObject? // point would be nil, if not in closure
                    student["latitude"] = point.coordinate.latitude as AnyObject?
                }
                
            }else {
                displayError(self, errorString: "Location data invalid, check your address")
                return
            }
            
            // gather user data from view and udacity singleton
            student["mapString"] = self.locationTextField.text! as AnyObject?  //from view
            student["mediaURL"] = self.linkTextField.text! as AnyObject?        //from view
            student["firstName"] = self.udacity.firstName as AnyObject?
            student["lastName"] = self.udacity.lastName as AnyObject?
            student["uniqueKey"] = self.udacity.userID as AnyObject?
            
            if let point = self.pointAnnotation {
                student["longitude"] = point.coordinate.longitude as AnyObject? // point would be nil, if not in closure
                student["latitude"] = point.coordinate.latitude as AnyObject?
            } else {
                displayError(self, errorString: "Location data invalid, longitude/latitude bad")
                return
            }
            
            // Post Student
            self.parse.postLocation(student, completionHandler: {(success, errorString) -> Void in
                if success {
                    DispatchQueue.main.async(execute: {
                        self.dismiss(animated: true, completion: nil)
                    })
                } else {
                    displayError(self, errorString: errorString)
                }
            })
        })
    }
    
    @IBAction func browseButtonPressed(_ sender: AnyObject) {
        
        // Private function
        // Tests URL first, if it thinks it can be opened then it is attemped
        func openAppLink(_ link: String) -> Bool {
            if UIApplication.shared.canOpenURL(URL(string: link)!) {
                let app = UIApplication.shared
                app.openURL(URL(string: linkTextField.text!)!)
                return true
                
            }
            return false
        }
        
        guard let originalString = linkTextField.text, originalString != "" else {
            return
        }
        
        if !openAppLink(originalString)
        {
            // check user input string for https:// or http://
            // if there is none attempt to add it to the string
            // app.open will fail if there is
            if !originalString.hasPrefix("https://")  ||
                !originalString.hasPrefix("http://") {
                    
                    if (openAppLink("http://" + originalString ) ) {
                        linkTextField.text = "http://" + originalString
                        _ = openAppLink(linkTextField.text!)
                        return
                        
                        // if http does not work try https
                    } else if (openAppLink("https://" + originalString) ) {
                        linkTextField.text = "https://" + originalString
                        _ = openAppLink(linkTextField.text!)
                        return
                    }
            }
            
        } else if (openAppLink(linkTextField.text!) ){
            return
        }
        else {
            // this may never be executed
            // canOpen doesn't care about the link being valid, just the http(s)
            displayError(self, errorString: "The link does appear to be valid")
            return
        }
        
    }
    
    @IBAction func findOnMapButtonPressed(_ sender: AnyObject) {
        
        searchForLocationDisplayOnMap( {(success, error) in
            if success {
                //Code
            } else {
                displayError(self, errorString: error)
            }
        } )
    }
}

