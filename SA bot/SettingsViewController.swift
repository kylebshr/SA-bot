//
//  SettingsViewController.swift
//  SA bot
//
//  Created by Kyle Bashour on 4/20/15.
//
//

import UIKit
import Parse

class SettingsViewController: UITableViewController {

    @IBOutlet weak var issuesSwitch: UISwitch!

    override func viewDidLoad() {

        let issuesOnly = NSUserDefaults.standardUserDefaults().boolForKey("issuesOnly")
        issuesSwitch.setOn(issuesOnly, animated: false)
    }
    
    @IBAction func issuesSwitchWasToggled(sender: AnyObject) {

        NSUserDefaults.standardUserDefaults().setBool(issuesSwitch.on, forKey: "issuesOnly")
    }
    
    @IBAction func closeWasPressed(sender: AnyObject) {

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func logOutWasPressed(sender: AnyObject) {

        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "issuesOnly")

        PFUser.logOutInBackgroundWithBlock({ finished in

            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let welcomeController = storyBoard.instantiateViewControllerWithIdentifier("WelcomeNavController") as! UINavigationController
            self.presentViewController(welcomeController, animated: true, completion: nil)
        })
    }
}
