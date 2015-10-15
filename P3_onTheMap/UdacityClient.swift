//
//  UdacityClient.swift
//  P3_onTheMap
//
//  Created by Michael Harper on 7/21/15.
//  Copyright (c) 2015 hxx. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

public class UdacityClient: NSObject {
    
    // Session
    var session: NSURLSession!
    
    // State
    var sessionID : String = ""
    var userID : String = ""
    var key : String = ""
    var firstName = ""
    var lastName = ""
    var expiration: String = ""
    var registered: Bool = false
    var isLoggedIn: Bool = false
    
    
    override init() {
        super.init()
        session = NSURLSession.sharedSession()
    }
    
    
    // MARK: LOGIN
    func login(hostViewController: UIViewController, username: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        // 2. build the string
        let urlString = UdacityClient.Constants.BaseURLSecure + "session"
        let url = NSURL(string: urlString)!
        
        /* 3A. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var err: NSError?
        let credentials = [ "udacity" : ["username" : username, "password" : password] ]
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(credentials, options: [])
        } catch let error as NSError {
            err = error
            request.HTTPBody = nil
            completionHandler(success: false, errorString: err?.localizedDescription)
            return
        }
        
        /* 4. Make the request */
        let task = self.session.dataTaskWithRequest(request) {data, response, error in
            
            if error != nil {
                print("Could not complete the request \(error)")
                completionHandler(success: false, errorString: error!.localizedDescription)
                return
            }
            
            /* 5A. Parse the data */
            //var parsingError: NSError? = nil
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            let jsonResult = (try! NSJSONSerialization.JSONObjectWithData(newData, options: [])) as! NSDictionary
            
            //check if user is registerd
            if let error = jsonResult.valueForKey("error") as? String {
                let errorMsg = jsonResult.valueForKey("error") as? String
                print("Oh No!!! \(error)")
                completionHandler(success: false, errorString: error)
                self.isLoggedIn = false
                return
                
            } else {
                print("setup account dictionary")
                if let accountDict = jsonResult.valueForKey("account") as? [String:AnyObject]
                {
                    
                    self.registered = (accountDict["registered"] as? Bool)!
                    if self.registered == true { self.isLoggedIn = true }
                    self.userID = (accountDict["key"] as? String)!
                    
                    let sessionDictionary = jsonResult.valueForKey("session") as! [String:AnyObject]
                    self.sessionID = ((sessionDictionary["id"] as? String))!
                    self.expiration = (sessionDictionary["expiration"] as? String)!
                    print(NSString(data: newData, encoding: NSUTF8StringEncoding))
                    self.getPublicUserData(self.userID)
                    completionHandler(success: true, errorString: "")
                }
            } // task
            
        }
        task.resume()
    }
    
    
    
    // MARK: Logout
    func logout() {
        
        // 1. setup parameters
        // none
        
        // 2. build the string
        let urlString = UdacityClient.Constants.BaseURLSecure + "session"
        let url = NSURL(string: urlString)!
        
        /* 3A. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as [NSHTTPCookie]! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-Token")
        }
        
        let task = self.session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
        
        task.resume()
        sessionID = ""
        userID = ""
        key = ""
        expiration = ""
        registered = false
        
    }
    
    // MARK: getPublicUserData
    // TODO: add callback to handle error
    func getPublicUserData(user: String) -> [String:AnyObject] {
        
        // Make sure user is logged in before getting data
        print("getting user data")
        var userData = [String:AnyObject]()
        if isLoggedIn == false {
            print("Udacity - not logged in")
            return userData
        }
        
        // 1. setup parameters
        // none
        
        // 2. build the string
        let urlString = UdacityClient.Constants.BaseURLSecure + "users/" + "\(self.userID)"
        let url = NSURL(string: urlString)!
        
        /* 3A. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        print( request.description )
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                
                print("Error getting public data \(error?.localizedDescription)")
                
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            let jsonResult = (try! NSJSONSerialization.JSONObjectWithData(newData, options: [])) as! NSDictionary
            
            //check if user is registerd
            if let error = jsonResult.valueForKey("error") as? String {
                //let errorMsg = jsonResult.valueForKey("error") as? String
                print("Oh No!!! \(error)")
                
            }
            if let userDict = jsonResult.valueForKey("user") as? [String:AnyObject] {
                self.firstName = (userDict["first_name"] as? String)!
                self.lastName = (userDict["last_name"] as? String)!
                userData = userDict
                print( "getPublicUserData has \(userData.count) elements")
                print( " name: \(self.firstName) \(self.lastName) " )
                self.printState()
                
            } else {
                print("could not extract first / last name from json")
            }
        }
        task.resume() //run task
        
        return userData
    }
    
    //MARK: Facebook Login
    // MARK: LOGIN
    func FBLogin(hostViewController: UIViewController, appId: String, FBToken: FBSDKAccessToken, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        // 2. build the string
        let urlString = UdacityClient.Constants.BaseURLSecure + "session"
        let url = NSURL(string: urlString)!
        
        /* 3A. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var err: NSError?
        let credentials = [ "facebook_mobile" : ["access_token" : FBToken.tokenString ]]
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(credentials, options: [])
        } catch let error as NSError {
            err = error
            request.HTTPBody = nil
            completionHandler(success: false, errorString: err?.localizedDescription)
            return
        }
        
        /* 4. Make the request */
        let task = self.session.dataTaskWithRequest(request) {data, response, error in
            
            if error != nil {
                print("Could not complete the request \(error)")
                completionHandler(success: false, errorString: error!.localizedDescription)
                return
            }
            
            /* 5A. Parse the data */
            //var parsingError: NSError? = nil
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            let jsonResult = (try! NSJSONSerialization.JSONObjectWithData(newData, options: [])) as! NSDictionary
            
            //check if user is registerd
            if let error = jsonResult.valueForKey("error") as? String {
                let errorMsg = jsonResult.valueForKey("error") as? String
                print("Oh No!!! \(error)")
                completionHandler(success: false, errorString: error)
                self.isLoggedIn = false
                return
                
            } else {
                print("setup account dictionary")
                if let accountDict = jsonResult.valueForKey("account") as? [String:AnyObject]
                {
                    
                    self.registered = (accountDict["registered"] as? Bool)!
                    if self.registered == true { self.isLoggedIn = true }
                    self.userID = (accountDict["key"] as? String)!
                    
                    let sessionDictionary = jsonResult.valueForKey("session") as! [String:AnyObject]
                    self.sessionID = ((sessionDictionary["id"] as? String))!
                    self.expiration = (sessionDictionary["expiration"] as? String)!
                    print(NSString(data: newData, encoding: NSUTF8StringEncoding))
                    self.getPublicUserData(self.userID)
                    completionHandler(success: true, errorString: "")
                }
            } // task
            
        }
        task.resume()
    }

    
    // MARK: - Shared Instance
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
    
    
    
    func printState() {
        print( "id:\(userID), registered:\(registered), expiration\(expiration)")
    }
    
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    func getUserInfo() -> ( [String:String] ) {
        
        //var dict: [String: AnyObject]
        //if firstName == "" || lastName == "" {
            getPublicUserData(userID)
        //}
        
        return [ "uniqueKey" : self.userID, "firstName": self.firstName, "lastName": self.lastName ]
        //return dict //return a proper dictionary
        
    }

}




extension UdacityClient {
    
    struct Constants {
        static let BaseURLSecure  = "https://www.udacity.com/api/"
    }
}

