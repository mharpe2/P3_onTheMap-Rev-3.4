//
//  LoginVC.swift
//  P3_onTheMap
//
//  Created by Michael Harper on 7/21/15.
//  Copyright (c) 2015 hxx. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

class LoginVC: UIViewController, FBSDKLoginButtonDelegate {
    
    
    @IBOutlet weak var loginButton: BorderedButton!
    @IBOutlet weak var headerTextLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    var tapRecognizer: UITapGestureRecognizer? = nil
    var client = UdacityClient.sharedInstance()
    var FBLoginButton: FBSDKLoginButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the UI
        self.configureUI()
        
        //Facebook Button
        FBLoginButton = FBSDKLoginButton()
        FBLoginButton.center = CGPoint(x: self.view.center.x, y: (self.view.frame.height) - FBLoginButton.frame.height)
        self.view.addSubview(FBLoginButton)
        self.FBLoginButton.delegate = self
        self.FBLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.addKeyboardDismissRecognizer()
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.removeKeyboardDismissRecognizer()
        self.unsubscribeToKeyboardNotifications()
    }
    
    // MARK: - Keyboard  func
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: - Udacity / Facebook login
    // If facebook token is not nil it will be used. otherwise username/password
    // text fields will be used for standard udacity login.
    @IBAction func loginButtonTouch(sender: AnyObject) {
        
        // if user is already logged in complete login
        if FBSDKAccessToken.currentAccessToken() != nil {
            client.FBLogin(self, appId: FacebookConst.appId, FBToken: FBSDKAccessToken.currentAccessToken())  { (success, errorString) in
                if success {
                    self.completeLogin()
                } else {
                    displayError(self, errorString: errorString)
                    shakeViewController(self)
                }
            }
        }else { // Udacity login
            client.login(self, username: usernameTextField.text!, password: passwordTextField.text!) { (success, errorString) in
                if success {
                    self.completeLogin()
                } else {
                    displayError(self, errorString: errorString)
                    shakeViewController(self)
                }
            }
        }
    }
    
    @IBAction func signupButton(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string:"https://www.udacity.com/account/auth#!/signup")!)
    }
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("mainTabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
            
            
        })
    }
    
    
    func configureUI() {
        
        /* Configure background gradient */
        self.view.backgroundColor = UIColor.clearColor()
        let colorTop = UIColor(red: 238/255.0, green: 169/255.0, blue: 17/255.0, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).CGColor
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        self.view.layer.insertSublayer(backgroundGradient, atIndex: 0)
        
        /* Configure tap recognizer */
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
    }
    
    //MARK: Facebook Delegates
    // facbook delegate login
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("Facebook Login - User Logged In")
        
        if ((error) != nil)
        {
            // Process error
            displayError(self, errorString: error.localizedDescription)
            shakeViewController(self)
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        
        // if facebook login completed, complete udacity login
        if FBSDKAccessToken.currentAccessToken() != nil {
            client.FBLogin(self, appId: FacebookConst.appId, FBToken: FBSDKAccessToken.currentAccessToken())  { (success, errorString) in
                if success {
                    self.completeLogin()
                } else {
                    displayError(self, errorString: errorString)
                    shakeViewController(self)
                }
            }
        }
    }
    
    
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("Facebook User Logged Out")
        
    }
    
    //MARK: Facebook Funcs
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: FBSDKAccessToken.currentAccessToken().userID, parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                displayError(self, errorString: error.description)
            }
            else
            {
                print("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                print( "User Name is: \(userName)")
                let userEmail : NSString = result.valueForKey("email") as! NSString
                print("User Email is: \(userEmail)")
            }
        })
    }
}


//MARK: Keyboard Notifications
extension LoginVC {
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            self.view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if keyboardAdjusted == true {
            self.view.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
}

