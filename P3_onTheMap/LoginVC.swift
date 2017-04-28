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
    /**
     Sent to the delegate when the button was used to login.
     - Parameter loginButton: the sender
     - Parameter result: The results of the login
     - Parameter error: The error (if any) from the login
     */
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        //code
    }

    
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.addKeyboardDismissRecognizer()
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
    
    func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: - Udacity / Facebook login
    // If facebook token is not nil it will be used. otherwise username/password
    // text fields will be used for standard udacity login.
    @IBAction func loginButtonTouch(_ sender: AnyObject) {
        
        // if user is already logged in complete login
        if FBSDKAccessToken.current() != nil {
            client.FBLogin(self, appId: FacebookConst.appId, FBToken: FBSDKAccessToken.current())  { (success, errorString) in
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
    
    @IBAction func signupButton(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string:"https://www.udacity.com/account/auth#!/signup")!)
    }
    
    func completeLogin() {
        DispatchQueue.main.async(execute: {
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "mainTabBarController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
            
            
        })
    }
    
    
    func configureUI() {
        
        /* Configure background gradient */
        self.view.backgroundColor = UIColor.clear
        let colorTop = UIColor(red: 238/255.0, green: 169/255.0, blue: 17/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).cgColor
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        self.view.layer.insertSublayer(backgroundGradient, at: 0)
        
        /* Configure tap recognizer */
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginVC.handleSingleTap(_:)))
        tapRecognizer?.numberOfTapsRequired = 1
        
    }
    
    //MARK: Facebook Delegates
    // facbook delegate login
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: NSError!) {
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
        if FBSDKAccessToken.current() != nil {
            client.FBLogin(self, appId: FacebookConst.appId, FBToken: FBSDKAccessToken.current())  { (success, errorString) in
                if success {
                    self.completeLogin()
                } else {
                    displayError(self, errorString: errorString)
                    shakeViewController(self)
                }
            }
        }
    }
    
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Facebook User Logged Out")
        
    }
    
    //MARK: Facebook Funcs
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: FBSDKAccessToken.current().userID, parameters: nil)
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                displayError(self, errorString: error.debugDescription)
            }
            else
            {
                print("fetched user: \(String(describing: result))")
                //let userName : NSString = result.value(forKey: "name") as! NSString
                guard let newResult = result as? [String: Any] else {
                    print("Cast to String : Any Failed")
                    return
                }
                let userName : String = newResult["name"] as! String

                print( "User Name is: \(userName)")
                let userEmail : String = newResult["email"] as! String
                print("User Email is: \(userEmail)")
            }
        })
    }
}


//MARK: Keyboard Notifications
extension LoginVC {
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            self.view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
        if keyboardAdjusted == true {
            self.view.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
}

