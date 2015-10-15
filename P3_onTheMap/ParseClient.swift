//
//  ParseClient.swift
//  P3_onTheMap
//
//  Created by Michael Harper on 8/11/15.
//  Copyright (c) 2015 hxx. All rights reserved.
//

import Foundation

class ParseClient: NSObject {
    
    // MARK: LOGIN
    func getStudentLocations(completionHandler: (success: Bool, errorString: String?, result:  [StudentInformation]?) -> Void )  {
        
            let request = NSMutableURLRequest(URL: NSURL(string: const.secureURL)!)
            request.addValue(const.appID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(const.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
            
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { data, response, error in
                if error != nil {
                    completionHandler( success: false, errorString: error!.localizedDescription, result: nil)
                    return
                }
                
                /* Error object */
                var dataError: NSError? = nil
                do {
                    let parsedResult: AnyObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    
                    if let x = parsedResult.valueForKey("results") as? [[String:AnyObject]] {
                        
                        let myResults = StudentInformation.studentsFromResults(x)
                        print( "GetStudentLocations myResults \(myResults.count)" )
                        completionHandler( success: true, errorString: dataError?.localizedDescription, result: myResults)
                    } else {
                        completionHandler(success: false, errorString: dataError?.localizedDescription, result: nil)
                        print("Error")
                    }
                } catch let error as NSError {
                    dataError = error
                } catch {
                    fatalError()
                }
            }
            task.resume()
    }
    
    
    // postStudentLocations    
    // Assumes studentdata is not nil
    func postStudentLocations(studentData: [String : AnyObject], completionHandler: (success: Bool, errorString: String?) -> Void )  {
        
        // extract data from dictionary
        let firstName = studentData["firstName"] as! String
        let lastName = studentData["lastName"]  as! String
        let uniqueKey = studentData["uniqueKey"] as! String
        let mapString = studentData["mapString"] as! String
        let mediaURL = studentData["mediaURL"] as! String
        let lat = studentData["latitude"] as! Double
        let long = studentData["longitude"] as! Double
        
        let student = [ "uniqueKey": uniqueKey, "firstName" : firstName, "lastName" : lastName, "mapString" : mapString, "mediaURL" : mediaURL, "latitude" : lat, "longitude": long ]
        
        let request = NSMutableURLRequest(URL: NSURL(string: const.secureURL)!)
        request.HTTPMethod = "POST"
        request.addValue(const.appID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(const.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var err: NSError?
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(student, options: [])
        } catch let error as NSError {
            err = error
            request.HTTPBody = nil
            print( err?.description )
            completionHandler(success: false, errorString: err?.localizedDescription)
            return
        }
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                print("error has occured in postStudentLocatoin\(error?.localizedDescription)" )
                completionHandler( success: false, errorString: error!.localizedDescription)
                return
            }
            
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            completionHandler(success: true, errorString: nil)
            return

        }
        task.resume()
    }

    // MARK: - Shared Instance
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}