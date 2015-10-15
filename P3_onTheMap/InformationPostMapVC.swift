//
//  InformationPostMapVCs.swift
//  P3_onTheMap
//
//  Created by Michael Harper on 9/11/15.
//  Copyright (c) 2015 hxx. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class InformationPostMapVC: UIViewController {
    
    
    @IBOutlet weak var submitButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var linkTextField: UITextField!

    
    var location = ""
    
    
    // Map Variables
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.mapType = MKMapType.Standard
        self.mapView.showsUserLocation = true
        self.mapView.removeAnnotations(self.mapView.annotations)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = location
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alert = UIAlertView(title: nil, message: "Place not found", delegate: self, cancelButtonTitle: "Try again")
                alert.show()
                self.dismissViewControllerAnimated(true, completion: nil)
                return
            }
            
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = self.location
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
            // ------------------------------------------------------------------------------------------------------------------------------
            //        CLGeocoder.reverseGeocodeLocation(<#CLGeocoder#>)
            //        CLGeocoder.reverseGeocodeLocation(currentLocation, completionHandler: { (placemarks: [AnyObject]!, error: NSError!) in
            //            if error == nil && placemarks.count > 0 {
            //                let location = placemarks[0] as CLPlacemark
            //                self.textField.text = "\(location.locality) \(location.thoroughfare) \(location.subThoroughfare)"
            //
            //            }
            //        })
        }

    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    
    /*
    // MARK: - MKMapViewDelegate
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    
    let reuseId = "pin"
    
    var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
    
    if pinView == nil {
    pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
    pinView!.canShowCallout = true
    pinView!.pinColor = .Red
    pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
    }
    else {
    pinView!.annotation = annotation
    }
    
    return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    
    if control == annotationView.rightCalloutAccessoryView {
    let app = UIApplication.sharedApplication()
    app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
    }
    }
    */
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
    }
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}


