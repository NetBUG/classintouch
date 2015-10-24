//
//  EntryViewController.swift
//  ClassInTouch
//
//  Created by Chris Findeisen on 10/23/15.
//  Copyright © 2015 ClassInTouch. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController, FBSDKLoginButtonDelegate {

    // MARK: Properties

    @IBOutlet weak var loginButton: FBSDKLoginButton!

    lazy var context: NSManagedObjectContext = {
        let delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return delegate.managedObjectContext
        }()
    
    lazy var networkHandler: PGNetworkHandler = {
        return PGNetworkHandler(baseURL: NSURL(string: "http://classintouch.me"))
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.readPermissions = ["public_profile", "email"]
        loginButton.delegate = self
    }

    // MARK: FBSDKLoginButtonDelegate
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error == nil && !result.isCancelled && result.grantedPermissions.contains("email") {
            login()
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User logged out.")
    }

    func login() {
        networkHandler.facebookLogin(FBSDKAccessToken.currentAccessToken().tokenString, context: context, success: { (result) -> Void in
            if let user = result.first as? User {
                if let id = user.id {
                    NSUserDefaults.standardUserDefaults().setObject(id, forKey: "UserID")
                }
            }

            self.dismissViewControllerAnimated(true, completion: nil)

            }, failure: nil, finish: {() -> Void in
            self.printUserData()
        })
    }
    
    func printUserData() {
        let graphRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if error != nil {
                print("Error: \(error)")
            } else {
                print("fetched user: \(result)")
                if let userName : NSString = result.valueForKey("name") as? NSString {
                    print("User Name is: \(userName)")
                }
                if let userEmail : NSString = result.valueForKey("email") as? NSString {
                    print("User Email is: \(userEmail)")
                }
            }
        })
    }
 

}

