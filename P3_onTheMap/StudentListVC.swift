//
//  StudentListVC.swift
//  P3_onTheMap
//
//  Created by Michael Harper on 8/19/15.
//  Copyright (c) 2015 hxx. All rights reserved.
//

import UIKit

class StudentListVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var studentsTableView: UITableView!
    var refreshButton: UIBarButtonItem! = nil
    var pinButton: UIBarButtonItem! = nil
    var pinImage: UIImage! = nil
    var parseMngr: ParseMngr!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parseMngr = ParseMngr.sharedInstance()
        
        //Mark: Custom Navigation buttons
        
        refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshButtonPressed:")
        
        pinImage = UIImage(named: "pin.pdf")!
        pinButton = UIBarButtonItem(image: pinImage, style: UIBarButtonItemStyle.Plain, target: self, action: "pinButtonPressed:")
        
        let rightButtons = [refreshButton!, pinButton!]
        self.navigationItem.rightBarButtonItems = rightButtons
        
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //update the table 
        parseMngr.updateStudentInformation { (success, errorString) -> Void in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    self.studentsTableView.reloadData()
                }

            } else {
               displayError(self, errorString: errorString)            }
        }

        self.studentsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    
    //MARK: tableView numberOfRowsInSection
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parseMngr.students.count
    }
    
    //MARK: tableView cellForRowAtIndexPath
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Get cell type
        let cellReuseIdentifier = "cell"
        let student = parseMngr.students[ indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        // Set cell defaults
        cell!.textLabel!.text = "\(student.firstName) \(student.lastName)"
        cell!.detailTextLabel?.text = student.mediaURL
        cell!.imageView!.image = UIImage(named: "pin.pdf")
        cell!.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        
        return cell!
    }
    
    //MARK: tableView didSelectRowAtIndexPath
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
        let app = UIApplication.sharedApplication()
        let studentAtIndex = parseMngr.students[ indexPath.row ]
        app.openURL(( NSURL( string: studentAtIndex.mediaURL))!)
    }

    @IBAction func logoutButtonPressed(sender: AnyObject) {
        UdacityClient.sharedInstance().logout()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func refreshButtonPressed(sender: UIButton) {
        //update the table
        parseMngr.updateStudentInformation { (success, errorString) -> Void in
            if success {
                print( "updateStudentInfo Count: \(self.parseMngr.students.count)" )
                dispatch_async(dispatch_get_main_queue()) {
                    self.studentsTableView.reloadData()
                }
                
            } else {
                print(errorString)
                displayError(self, errorString: errorString)
            }
        }
    }
    
    func pinButtonPressed(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingController") 
            self.presentViewController(controller, animated: true, completion: nil)
    })
    }

}