//
//  StudentMngr.swift
//  P3_onTheMap
//
//  Created by Michael Harper on 10/12/15.
//  Copyright © 2015 hxx. All rights reserved.
//

// For Future use

class StudentMngr {
    
    // udacity students
    var students: [StudentInformation] = [StudentInformation]()
    
    // MARK: - Shared Instance
    class func sharedInstance() -> StudentMngr {
        struct Singleton {
            static var sharedInstance = StudentMngr()
        }
        return Singleton.sharedInstance
    }

    
}
