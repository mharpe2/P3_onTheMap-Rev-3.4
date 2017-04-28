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
    func getStudentLocations(_ completionHandler: @escaping (_ success: Bool, _ errorString: String?, _ result:  [StudentInformation]?) -> Void )  {
        
            var request = URLRequest(url: URL(string: const.secureURL)!)
            request.addValue(const.appID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(const.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
            
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { data, response, error in
                if error != nil {
                    completionHandler( false, error!.localizedDescription, nil)
                    return
                }
                
                /* Error object */
                var dataError: NSError? = nil
                let  parsedResult: NSDictionary
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                    
                    if let x = parsedResult.value(forKey: "results") as? [[String:AnyObject]] {
                        
                        let myResults = StudentInformation.studentsFromResults(x)
                        print( "GetStudentLocations myResults \(myResults.count)" )
                        completionHandler( true, dataError?.localizedDescription, myResults)
                    } else {
                        completionHandler(false, dataError?.localizedDescription, nil)
                        print("Error")
                    }
                } catch let error as NSError {
                    dataError = error
                } catch {
                    fatalError()
                }
            }) 
            task.resume()
    }
    
    
    // postStudentLocations    
    // Assumes studentdata is not nil
    func postStudentLocations(_ studentData: [String : AnyObject], completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void )  {
        
        // extract data from dictionary
        let firstName = studentData["firstName"] as! String
        let lastName = studentData["lastName"]  as! String
        let uniqueKey = studentData["uniqueKey"] as! String
        let mapString = studentData["mapString"] as! String
        let mediaURL = studentData["mediaURL"] as! String
        let lat = studentData["latitude"] as! Double
        let long = studentData["longitude"] as! Double
        
        let student = [ "uniqueKey": uniqueKey, "firstName" : firstName, "lastName" : lastName, "mapString" : mapString, "mediaURL" : mediaURL, "latitude" : lat, "longitude": long ] as [String : Any]
        
        var request = URLRequest(url: URL(string: const.secureURL)!)
        request.httpMethod = "POST"
        request.addValue(const.appID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(const.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var err: NSError?
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: student, options: [])
        } catch let error as NSError {
            err = error
            request.httpBody = nil
            print( err?.description )
            completionHandler(false, err?.localizedDescription)
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if error != nil {
                print("error has occured in postStudentLocatoin\(error?.localizedDescription)" )
                completionHandler( false, error!.localizedDescription)
                return
            }
            
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
            completionHandler(true, nil)
            return

        }) 
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
