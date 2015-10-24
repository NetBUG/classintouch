//
//  AskViewController.swift
//  ClassInTouch
//
//  Created by Justin Jia on 10/24/15.
//  Copyright © 2015 ClassInTouch. All rights reserved.
//

import UIKit

class AskViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func askButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
