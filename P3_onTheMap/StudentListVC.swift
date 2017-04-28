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
        
        refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(StudentListVC.refreshButtonPressed(_:)))
        
        pinImage = UIImage(named: "pin.pdf")!
        pinButton = UIBarButtonItem(image: pinImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(StudentListVC.pinButtonPressed(_:)))
        
        let rightButtons = [refreshButton!, pinButton!]
        self.navigationItem.rightBarButtonItems = rightButtons
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //update the table 
        parseMngr.updateStudentInformation { (success, errorString) -> Void in
            if success {
                DispatchQueue.main.async {
                    self.studentsTableView.reloadData()
                }

            } else {
               displayError(self, errorString: errorString)            }
        }

        self.studentsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    
    //MARK: tableView numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parseMngr.students.count
    }
    
    //MARK: tableView cellForRowAtIndexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get cell type
        let cellReuseIdentifier = "cell"
        let student = parseMngr.students[ indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        // Set cell defaults
        cell!.textLabel!.text = "\(student.firstName) \(student.lastName)"
        cell!.detailTextLabel?.text = student.mediaURL
        cell!.imageView!.image = UIImage(named: "pin.pdf")
        cell!.imageView!.contentMode = UIViewContentMode.scaleAspectFit
        
        return cell!
    }
    
    //MARK: tableView didSelectRowAtIndexPath
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let app = UIApplication.shared
        let studentAtIndex = parseMngr.students[ indexPath.row ]
        app.openURL(( URL( string: studentAtIndex.mediaURL))!)
    }

    @IBAction func logoutButtonPressed(_ sender: AnyObject) {
        UdacityClient.sharedInstance().logout()
        self.dismiss(animated: true, completion: nil)
    }
    
    func refreshButtonPressed(_ sender: UIButton) {
        //update the table
        parseMngr.updateStudentInformation { (success, errorString) -> Void in
            if success {
                print( "updateStudentInfo Count: \(self.parseMngr.students.count)" )
                DispatchQueue.main.async {
                    self.studentsTableView.reloadData()
                }
                
            } else {
                print(errorString)
                displayError(self, errorString: errorString)
            }
        }
    }
    
    func pinButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async(execute: {
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "InformationPostingController") 
            self.present(controller, animated: true, completion: nil)
    })
    }

}
