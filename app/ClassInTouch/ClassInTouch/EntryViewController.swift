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
        return PGNetworkHandler(baseURL: NSURL(string: "http://classintouch.club"))
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.readPermissions = ["public_profile"]
        loginButton.delegate = self
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
    }

    // MARK: FBSDKLoginButtonDelegate
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error == nil && !result.isCancelled {
            let graphRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                if error != nil {
                    print("Error: \(error)")
                } else {
                    print("fetched user: \(result)")

                    guard let facebookID = result.valueForKey("id") as? String else {
                        return
                    }

                    guard let username = result.valueForKey("name") as? String else {
                        return
                    }

                    guard let facebookIDInt = Int(facebookID) else {
                        return
                    }

                    do {
                        NSUserDefaults.standardUserDefaults().setInteger(facebookIDInt, forKey: "UserID")
                        NSUserDefaults.standardUserDefaults().setObject(facebookID, forKey: "FacebookID")
                        try self.context.save("User", with: ["name": username, "id": NSNumber(integer: facebookIDInt)], mapping: PGNetworkMapping.userMapping)
                        try self.context.save()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } catch {
                        // TODO: Handle error in the future
                    }
                }
            })
        }
    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        do {
            let id = NSUserDefaults.standardUserDefaults().integerForKey("UserID")
            if let user = try context.object("User", identifier: id, key: "id") as? User {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("UserID")
                NSUserDefaults.standardUserDefaults().removeObjectForKey("FacebookID")
                context.deleteObject(user)
            }
        } catch {
            // TODO: Handle error in the future
        }
    }

}

