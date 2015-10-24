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
                    if let username : NSString = result.valueForKey("name") as? NSString {
                        do {
                            try self.context.save("User", with: ["name": username, "id": NSNumber(integer: 0)], mapping: PGNetworkMapping.userMapping)
                            try self.context.save()
                            self.dismissViewControllerAnimated(true, completion: nil)
                        } catch {
                            // TODO: Handle error in the future
                        }
                    }
                }
            })
        }
    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        do {
            if let user = try context.object("User", identifier: 0, key: "id") as? User {
                context.deleteObject(user)
            }
        } catch {
            // TODO: Handle error in the future
        }
    }

}

