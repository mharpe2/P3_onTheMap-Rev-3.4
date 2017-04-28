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

open class UdacityClient: NSObject {
    
    // Session
    var session: URLSession!
    
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
        session = URLSession.shared
    }
    
    
    // MARK: LOGIN
    func login(_ hostViewController: UIViewController, username: String, password: String, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        // 2. build the string
        let urlString = UdacityClient.Constants.BaseURLSecure + "session"
        let url = URL(string: urlString)!
        
        /* 3A. Configure the request */
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var err: NSError?
        let credentials = [ "udacity" : ["username" : username, "password" : password] ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: credentials, options: [])
        } catch let error as NSError {
            err = error
            request.httpBody = nil
            completionHandler(false, err?.localizedDescription)
            return
        }
        
        /* 4. Make the request */
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
    
            guard let data = data, error == nil else {
                print("Error:\(String(describing: error)))")
                completionHandler(false, error!.localizedDescription)
                return
            }
//            if error != nil {
//                print("Could not complete the request \(String(describing: error))")
//                
//                return
//            }
            
            /* 5A. Parse the data */
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            
            let jsonResult = (try! JSONSerialization.jsonObject(with: newData, options: [])) as! NSDictionary
            
            //check if user is registerd
            if let error = jsonResult.value(forKey: "error") as? String {
                let errorMsg = jsonResult.value(forKey: "error") //as? String
                print("\(String(describing: errorMsg)) with \(error)")
                completionHandler(false, error)
                self.isLoggedIn = false
                return
                
            } else {
                print("setup account dictionary")
                if let accountDict = jsonResult.value(forKey: "account") as? [String:AnyObject]
                {
                    
                    self.registered = (accountDict["registered"] as? Bool)!
                    if self.registered == true { self.isLoggedIn = true }
                    self.userID = (accountDict["key"] as? String)!
                    
                    let sessionDictionary = jsonResult.value(forKey: "session") as! [String:AnyObject]
                    self.sessionID = ((sessionDictionary["id"] as? String))!
                    self.expiration = (sessionDictionary["expiration"] as? String)!
                    
                    let responseString = String(data: newData, encoding: .utf8)
                    print("Response: \(String(describing: responseString))")
                    //print(String(data: newData, encoding: String.Encoding.utf8.rawValue))
                    _ = self.getPublicUserData(self.userID)
                    completionHandler(true, "")
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
        let url = URL(string: urlString)!
        
        /* 3A. Configure the request */
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies as [HTTPCookie]! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-Token")
        }
        
       // let task = self.session.dataTask(with: request, completionHandler: { data, response, error in
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {
                print("Error:\(String(describing: error)))")
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            let responseString = String(data: newData, encoding: .utf8)
            print("Response: \(String(describing: responseString))")
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
    func getPublicUserData(_ user: String) -> [String:AnyObject] {
        
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
        let url = URL(string: urlString)!
        
        /* 3A. Configure the request */
        var request =  URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        print( request.description )
        //let session = URLSession.shared
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {
                print("Error:\(String(describing: error)))")
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            let jsonResult = (try! JSONSerialization.jsonObject(with: newData, options: [])) as! NSDictionary
            
            //check if user is registerd
            if let error = jsonResult.value(forKey: "error") as? String {
                //let errorMsg = jsonResult.valueForKey("error") as? String
                print("Oh No!!! \(error)")
                
            }
            if let userDict = jsonResult.value(forKey: "user") as? [String:AnyObject] {
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
    func FBLogin(_ hostViewController: UIViewController, appId: String, FBToken: FBSDKAccessToken, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        // 2. build the string
        let urlString = UdacityClient.Constants.BaseURLSecure + "session"
        var request = URLRequest(url: URL(string: urlString)!)
        
        /* 3A. Configure the request */
        //let request = URL(string: url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var err: NSError?
        let credentials = [ "facebook_mobile" : ["access_token" : FBToken.tokenString ]]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: credentials, options: [])
        } catch let error as NSError {
            err = error
            request.httpBody = nil
            completionHandler(false, err?.localizedDescription)
            return
        }
        
        /* 4. Make the request */
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {
                print("Error:\(String(describing: error)))")
                return
            }
            
            /* 5A. Parse the data */
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            let jsonResult = (try! JSONSerialization.jsonObject(with: newData, options: [])) as! NSDictionary
            
            //check if user is registerd
            if let error = jsonResult.value(forKey: "error") as? String {
                let errorMsg = jsonResult.value(forKey: "error") as? String
                print("Oh No!!! \(error)")
                completionHandler(false, error)
                self.isLoggedIn = false
                return
                
            } else {
                print("setup account dictionary")
                if let accountDict = jsonResult.value(forKey: "account") as? [String:AnyObject]
                {
                    
                    self.registered = (accountDict["registered"] as? Bool)!
                    if self.registered == true { self.isLoggedIn = true }
                    self.userID = (accountDict["key"] as? String)!
                    
                    let sessionDictionary = jsonResult.value(forKey: "session") as! [String:AnyObject]
                    self.sessionID = ((sessionDictionary["id"] as? String))!
                    self.expiration = (sessionDictionary["expiration"] as? String)!
                    
                    let responseString = String(data: newData, encoding: .utf8)
                    print("Response: \(String(describing: responseString))")

                    
//                    print(NSString(data: newData, encoding: String.Encoding.utf8))
//                    self.getPublicUserData(self.userID)
                    completionHandler(true, "")
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
    
    class func escapedParameters(_ parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }
    
    func getUserInfo() -> ( [String:String] ) {
        _ = getPublicUserData(userID)
        return [ "uniqueKey" : self.userID, "firstName": self.firstName, "lastName": self.lastName ]
        
    }

}




extension UdacityClient {
    
    struct Constants {
        static let BaseURLSecure  = "https://www.udacity.com/api/"
    }
}

