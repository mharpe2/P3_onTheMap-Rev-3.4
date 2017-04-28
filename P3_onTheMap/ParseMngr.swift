//
//  ParseMngr.swift
//  P3_onTheMap
//
//  Created by Michael Harper on 9/7/15.
//  Copyright (c) 2015 hxx. All rights reserved.
//

import Foundation

class ParseMngr: NSObject {
    
    var students: [StudentInformation] = []
    var parseClient: ParseClient!
    var currentUserInformation: StudentInformation!
    
    
    override init() {
        super.init()
        parseClient = ParseClient.sharedInstance()
        
    }
    
    // perform update by network
    func updateStudentInformation( _ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void ) {
        
        parseClient.getStudentLocations { (success, errorString, result) -> Void in
            if success {
                self.students = result!
    
                //sort array by last name, then first
                self.students.sort { $0.updatedAt < $1.updatedAt }
                completionHandler(true, nil)
            } else {
                 completionHandler(false, errorString)
            }
        }
    }
    
    func refreshStudentInformation() {
        students.removeAll(keepingCapacity: true)
        
        self.updateStudentInformation { (success, errorString) -> Void in
            if success {
                return
            } else {
                print(errorString)
            }
        }
    }
    
    func postLocation( _ studentDict: [String:AnyObject], completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        parseClient.postStudentLocations(studentDict, completionHandler: { (success, errorString) -> Void in
            if success {
                completionHandler(true, nil)
                self.currentUserInformation = StudentInformation(dictionary: studentDict)
                return
            } else {
                completionHandler(false, errorString)
                return
            }
        }) // completionHandler
    }
    
    // MARK: - Shared Instance
    class func sharedInstance() -> ParseMngr {
        
        struct Singleton {
            static var sharedInstance = ParseMngr()
        }
        
        return Singleton.sharedInstance
    }
}
