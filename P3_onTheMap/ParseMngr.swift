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
    func updateStudentInformation( completionHandler: (success: Bool, errorString: String?) -> Void ) {
        
        parseClient.getStudentLocations { (success, errorString, result) -> Void in
            if success {
                self.students = result!
    
                //sort array by last name, then first
                self.students.sortInPlace { $0.updatedAt < $1.updatedAt }
                completionHandler(success: true, errorString: nil)
            } else {
                 completionHandler(success: false, errorString: errorString)
            }
        }
    }
    
    func refreshStudentInformation() {
        students.removeAll(keepCapacity: true)
        
        self.updateStudentInformation { (success, errorString) -> Void in
            if success {
                return
            } else {
                print(errorString)
            }
        }
    }
    
    func postLocation( studentDict: [String:AnyObject], completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        parseClient.postStudentLocations(studentDict, completionHandler: { (success, errorString) -> Void in
            if success {
                completionHandler(success: true, errorString: nil)
                self.currentUserInformation = StudentInformation(dictionary: studentDict)
                return
            } else {
                completionHandler(success: false, errorString: errorString)
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