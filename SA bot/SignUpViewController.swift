//
//  WelcomeController.swift
//  SA bot
//
//  Created by Kyle Bashour on 2/27/15.
//
//

import UIKit
import Parse

class SignUpViewController: UITableViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set the delegate of the text field and pop up the keyboard
        usernameField.becomeFirstResponder()

        // Set the title and disable the back button
        navigationItem.title = "Sign Up"
        navigationItem.hidesBackButton = false
    }

    // MARK: Linked actions

    func signUpWasPressed() {

        if usernameField.text == "" {

            showAlert("Please enter a username", message: nil)
            return
        }
        else if count(passwordField.text) < 6 {

            showAlert("Your password must be six characters or longer", message: nil)
            return
        }
        else if passwordField.text != confirmField.text {

            showAlert("Your password and your confirmation don't match", message: nil)
            return
        }

        // hide the sign up button, show the spinner
        signUpLabel.hidden = true
        activityIndicator.startAnimating()

        let user = PFUser()

        user.username = usernameField.text
        user.password = passwordField.text

        user.signUpInBackgroundWithBlock({ (success, error) in

            self.activityIndicator.stopAnimating()
            self.signUpLabel.hidden = false

            if success {

                self.showMainView()
            }
            else {
                NSLog("Server error: \(error!.localizedDescription)")
                var message = "There was an error signing up:\n"
                if let errorString = error?.userInfo?["error"] as? String {

                    message += errorString
                }

                self.showAlert("Error", message: message)
            }
        })
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        tableView.deselectRowAtIndexPath(indexPath, animated: false)

        if indexPath.section == 1 && indexPath.row == 0 && !activityIndicator.isAnimating() {

            signUpWasPressed()
        }
    }

    // shows a generic alert with the given title and message
    func showAlert(title: String, message: String?) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(okButton)
        presentViewController(alert, animated: true, completion: nil)
    }

    // Show the main vc after getting a uid
    func showMainView() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewControllerWithIdentifier("TabController") as! TabController

        presentViewController(mainVC, animated: true, completion: nil)
    }
}