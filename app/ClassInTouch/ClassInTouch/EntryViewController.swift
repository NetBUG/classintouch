//
//  EntryViewController.swift
//  ClassInTouch
//
//  Created by Chris Findeisen on 10/23/15.
//  Copyright © 2015 ClassInTouch. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    
    lazy var context: NSManagedObjectContext = {
        let delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return delegate.managedObjectContext
        }()
    
    lazy var networkHandler: PGNetworkHandler = {
        return PGNetworkHandler(baseURL: NSURL(string: "http://dev.classintouch.me"))
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            self.dismissViewControllerAnimated(false, completion: nil)
        }
        else
        {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "email"]
            loginView.delegate = self
        }
        
    }
    
    // Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                login()
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    func login()
    {
        networkHandler.GET("register.json", parameters: ["access_token": FBSDKAccessToken.currentAccessToken()], to: self.context, mapping: PGNetworkMapping.userMapping, success: { (result: [AnyObject]!) -> Void in // Success block (async, will execute if the everything is correct)
            self.printUserData()
            self.dismissViewControllerAnimated(false, completion: nil)
            
            }, failure: { (error: NSError!) -> Void in // failure block (async, will execute if the request -> failed, JSON -> failed, or Core Data -> failed)
                print(error)
            }) { () -> Void in // finish block (async, will execute no matter the GET operation is succeed or not, always after success or failure block)
        }
    }
    
    func printUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                print("User Name is: \(userName)")
                let userEmail : NSString = result.valueForKey("email") as! NSString
                print("User Email is: \(userEmail)")
            }
        })
    }
 

}

