////
////  UdacityClient.swift
////  P3_onTheMap
////
////  Created by Michael Harper on 7/21/15.
////  Copyright (c) 2015 hxx. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//
//var t: StudentInformation
//class UdacityClient : NSObject {
//    
//    // Session
//    var session: NSURLSession!
//    
//    var s: StudentInformation!
//    
//    // State
//    var sessionID : String? = nil
//    var userID : String? = nil
//    var key : String? = nil
//    var expiration: String? = nil
//    var registered: Bool? = false
//    
//    var isLoggedIn: Bool = false
//    
//    override init() {
//        super.init()
//        session = NSURLSession.sharedSession()
//    }
//    
//    
//    
//    // MARK: LOGIN
//    func login(hostViewController: UIViewController, username: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
//        
//        
//        // 2. build the string
//        let urlString = UdacityClient.Constants.BaseURLSecure + "session"
//        let url = NSURL(string: urlString)!
//        
//        /* 3A. Configure the request */
//        let request = NSMutableURLRequest(URL: url)
//        request.HTTPMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
//        
//        /* 4. Make the request */
//        let task = self.session.dataTaskWithRequest(request) {data, response, downloadError in
//            
//            if let error = downloadError {
//                println("Could not complete the request \(error)")
//                completionHandler(success: false, errorString: error.description)
//            }
//            
//            /* 5A. Parse the data */
//            var parsingError: NSError? = nil
//            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
//            let jsonResult = NSJSONSerialization.JSONObjectWithData(newData, options: nil, error: nil) as! NSDictionary
//            
//            //check if user is registerd
//            if let error = jsonResult.valueForKey("error") as? String {
//                let errorMsg = jsonResult.valueForKey("error") as? String
//                println("Oh No!!! \(error)")
//                completionHandler(success: false, errorString: error)
//                self.isLoggedIn = false
//                
//            } else {
//                println("setup account dictionary")
//                if let accountDict = jsonResult.valueForKey("account") as? [String:AnyObject] {
//                    self.registered = accountDict["registered"] as? Bool
//                    if self.registered == true { self.isLoggedIn = true }
//                    self.userID = accountDict["key"] as? String
//                    
//                    let sessionDictionary = jsonResult.valueForKey("session") as! [String:AnyObject]
//                    self.sessionID = sessionDictionary["id"] as? String
//                    self.expiration = sessionDictionary["expiration"] as? String
//                    println(NSString(data: newData, encoding: NSUTF8StringEncoding))
//                    completionHandler(success: true, errorString: "")
//                }
//            } // task
//            
//        }
//        task.resume()
//    }
//    
//    // MARK: Logout
//    func logout() {
//        
//        // 1. setup parameters
//        // none
//        
//        // 2. build the string
//        let urlString = UdacityClient.Constants.BaseURLSecure + "session"
//        let url = NSURL(string: urlString)!
//        
//        /* 3A. Configure the request */
//        let request = NSMutableURLRequest(URL: url)
//        request.HTTPMethod = "DELETE"
//        
//        var xsrfCookie: NSHTTPCookie? = nil
//        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
//        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
//            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
//        }
//        if let xsrfCookie = xsrfCookie {
//            request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
//        }
//        //let session = NSURLSession.sharedSession()
//        let task = self.session.dataTaskWithRequest(request) { data, response, error in
//            if error != nil { // Handle error…
//                return
//            }
//            
//            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
//            println(NSString(data: newData, encoding: NSUTF8StringEncoding))
//        }
//        
//        task.resume()
//        sessionID = nil
//        userID = nil
//        key = nil
//        expiration = nil
//        registered = nil
//    }
//    
//    // MARK: getPublicUserData
//    func getPublicUserData(user: String) -> [String:AnyObject]? {
//        
//        // Make sure user is logged in before getting data
//        println("getting user data")
//        if isLoggedIn == false {
//            println("Udacity - not logged in")
//            return nil
//        }
//        
//        var userData = [String:AnyObject]()
//        
//        // 1. setup parameters
//        // none
//        
//        // 2. build the string
//        let urlString = UdacityClient.Constants.BaseURLSecure + "users/" + "\(self.userID!)"
//        let url = NSURL(string: urlString)!
//        
//        /* 3A. Configure the request */
//        let request = NSMutableURLRequest(URL: url)
//        request.HTTPMethod = "GET"
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        
//        println( request.description )
//        
//        let session = NSURLSession.sharedSession()
//        let task = session.dataTaskWithRequest(request) { data, response, error in
//            if error != nil { // Handle error...
//                println("Error getting public data")
//                return
//            }
//            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
//            userData = NSJSONSerialization.JSONObjectWithData(newData, options: nil, error: nil) as! NSDictionary as! [String : AnyObject]
//            
//            
//            println("User Data for \(user)" )
//            println(NSString(data: newData, encoding: NSUTF8StringEncoding))
//        }
//        task.resume() //run task
//        
//        return userData
//        
//        
//    }
//    
//    
//    // MARK: - Shared Instance
//    class func sharedInstance() -> UdacityClient {
//        
//        struct Singleton {
//            static var sharedInstance = UdacityClient()
//        }
//        
//        return Singleton.sharedInstance
//    }
//    
//    func printState() {
//        println( "id:\(userID), registered:\(registered), expiration\(expiration)")
//    }
//    
//    class func escapedParameters(parameters: [String : AnyObject]) -> String {
//        
//        var urlVars = [String]()
//        
//        for (key, value) in parameters {
//            
//            /* Make sure that it is a string value */
//            let stringValue = "\(value)"
//            
//            /* Escape it */
//            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
//            
//            /* Append it */
//            urlVars += [key + "=" + "\(escapedValue!)"]
//            
//        }
//        
//        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
//    }
//    
//}
//
//
