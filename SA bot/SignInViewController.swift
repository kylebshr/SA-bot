//
//  SignInViewController.swift
//  SA bot
//
//  Created by Kyle Bashour on 4/17/15.
//
//

import UIKit
import Parse

class SignInViewController: UITableViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // set the delegate of the text field and pop up the keyboard
        usernameField.becomeFirstResponder()

        // Set the title and disable the back button
        navigationItem.title = "Log In"
        navigationItem.hidesBackButton = false
    }

    // MARK: Linked actions

    func signInWasPressed() {


        if usernameField.text == "" || passwordField.text == "" {

            showAlert("Error", message: "Make sure you've entered a username and password.")
            return
        }

        // hide the sign up button, show the spinner
        loginLabel.hidden = true
        activityIndicator.startAnimating()

        PFUser.logInWithUsernameInBackground(usernameField.text, password: passwordField.text, block: { (user, error) in

            self.activityIndicator.stopAnimating()
            self.loginLabel.hidden = false

            if user != nil {

                self.showMainView()
            }
            else {
                NSLog("Server error: \(error!.localizedDescription)")
                var message = "There was an error logging in:\n"
                if let errorString = error?.userInfo?["error"] as? String {

                    message += errorString
                }

                self.showAlert("Error", message: message)
            }

        })
    }

    // shows a generic alert with the given title and message
    func showAlert(title: String, message: String) {

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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        tableView.deselectRowAtIndexPath(indexPath, animated: false)

        if indexPath.section == 1 && indexPath.row == 0 && !activityIndicator.isAnimating() {

            signInWasPressed()
        }
    }
}