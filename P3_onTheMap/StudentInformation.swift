//
//  StudentsData.swift
//  P3_onTheMap
//
//  Created by Michael Harper on 8/11/15.
//  Copyright (c) 2015 hxx. All rights reserved.
//

//import Foundation

struct StudentInformation {
    
    // constants
    struct const {
        static let noData = "No data available"
    }
    
    var objectId: String = const.noData
    var uniqueKey = const.noData
    var firstName = const.noData
    var lastName = const.noData
    var mapString = const.noData
    var mediaURL = const.noData
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var updatedAt: String = const.noData
    
    init() { }
    
    // Construct a StudentsData from a dictionary
    // unwrap all optionals, 
    init(dictionary: [String : AnyObject]) {

        if let objectId = dictionary["objectId"] as? String {
            self.objectId = objectId
        }
        
        if let uniqueKey = dictionary["uniqueKey"] as? String {
            self.uniqueKey = uniqueKey
        }
        if let firstName = dictionary["firstName"] as? String {
            self.firstName = firstName
        }
        
        if let lastName = dictionary["lastName"] as? String {
            self.lastName = lastName
        }
        
        if let mapString = dictionary["mapString"] as? String {
            self.mapString = mapString
        }
        
        if let mediaURL = dictionary["mediaURL"] as? String {
            self.mediaURL = mediaURL
        }
        
        if let latitude = dictionary["latitude"] as? Double {
            self.latitude = latitude
        }
        
        if let longitude = dictionary["longitude"] as? Double   {
            self.longitude = longitude
        }
        
        if let updateAt = dictionary["updatedAt"] as? String {
            self.updatedAt = updateAt
        }

        
    }
    
    /* Helper: Given an array of dictionaries, convert them to an array of Student objects */
    static func studentsFromResults(_ results: [[String : AnyObject]]) -> [StudentInformation] {
        var students = [StudentInformation]() 
       
        for result in results {
            students.append( StudentInformation(dictionary: result) )
        }
        
        return students
    }
    
}
