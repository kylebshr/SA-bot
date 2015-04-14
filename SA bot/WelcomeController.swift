//
//  WelcomeController.swift
//  SA bot
//
//  Created by Kyle Bashour on 2/27/15.
//
//

import UIKit
import Alamofire

class WelcomeController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var phoneNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set the delegate of the text field and pop up the keyboard
        phoneTextField.delegate = self
        phoneTextField.becomeFirstResponder()

        // Set the title and disable the back button
        self.navigationItem.title = "Welcome"
        self.navigationItem.hidesBackButton = true
    }

    // MARK: Linked actions

    @IBAction func signUpWasPressed(sender: AnyObject) {

        // only proceed if the phone number is probably legit
        if verifyPhone() {

            // hide the sign up button, show the spinner
            signUpButton.hidden = true
            activityIndicator.startAnimating()

            // send the phone to the server
            sendCode()
        }
    }

    // send the phone number to the server and the code to the person
    func sendCode() {

        // send the request
        Alamofire.request(.POST, baseURL + "register", parameters: ["phone": phoneNumber])
            .response { (_, response, json, error) in

                // stop the spinner
                self.activityIndicator.stopAnimating()
                self.signUpButton.hidden = false

                // check if there was an error
                if error != nil {

                    NSLog("Server error: \(error!.localizedDescription)")
                    self.showAlert("Server Error", message: "There was an error signing up")
                }
                // if no error, show the code input popup
                else {

                    self.showCodeAlert()
                }
        }
    }

    // send the code that the user entered to verify it
    func sendCodeToServer(code: String) {

        // disable the button while we send it
        signUpButton.enabled = false

        // send the request w/ the phone number and the code
        Alamofire.request(.POST, baseURL + "verify", parameters: ["phone": phoneNumber, "code": code])
            .responseJSON { (_, _, json, error) in

                // re-enable the sign up button
                self.signUpButton.enabled = true

                // Show the error alert if there is one
                if error != nil {

                    self.showAlert("Server Error", message: "You probably entered the wrong code, or our server is down")
                }
                // success: save the user id in our user defaults and show the main screen
                else {

                    if let dict = json as? NSDictionary {
                        if let uid = dict.objectForKey("uuid") as? String {

                            NSUserDefaults.standardUserDefaults().setObject(uid, forKey: "uid")
                            self.showMainView()
                        }
                    }
                }
        }
    }

    // MARK: Other functions

    // shows a popup for the texted code to be entered
    func showCodeAlert() {

        // Set the title
        let alertController = UIAlertController(title: nil, message: "Enter the six digit code we just sent you", preferredStyle: .Alert)

        // the login button with the handler
        let loginAction = UIAlertAction(title: "Login", style: .Default) { (_) in

            let loginTextField = alertController.textFields![0] as! UITextField

            self.sendCodeToServer(loginTextField.text)
        }

        // don't enable it yet
        loginAction.enabled = false

        // add the textfield with a placeholder.
        alertController.addTextFieldWithConfigurationHandler { (textField) in

            textField.placeholder = "123456"
            textField.keyboardType = .NumberPad
            textField.textAlignment = .Center

            // if 6 chars are entered, enable the login button
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                loginAction.enabled = count(textField.text) == 6
            }
        }

        // needs a cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)

        // add the buttons, then present it
        alertController.addAction(cancelAction)
        alertController.addAction(loginAction)

        self.presentViewController(alertController, animated: true, completion: nil)
    }

    // shows a generic alert with the given title and message
    func showAlert(title: String, message: String) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // Format the string as they type the phone number
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        let originalString: NSString = textField.text as NSString

        // Get the string and a string of just the numbers
        let newString = originalString.stringByReplacingCharactersInRange(range, withString: string)
        let components: NSArray = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        let decimalString: NSString = components.componentsJoinedByString("")

        // get the number of digits
        let length = decimalString.length

        // Check if there's a leading '1'
        var hasLeadingOne: Bool = (length > 0) && (decimalString.substringToIndex(1) == "1")

        // If it's over 11 chars, no more typing for you
        if (length > 11) {
            textField.text = originalString as String
            return false
        }
        // if there's 10 chars and no leading 1, no more typing for you either
        if (length > 10 && !hasLeadingOne) {
            textField.text = originalString as String
            return false
        }

        // If we're here, we need to format stuff
        // set up index and the new string
        var index = 0
        var formattedString = ""

        // At this point we check if there's a leading 1, and add it if so
        if (hasLeadingOne && length > 1) {
            formattedString += "1 "
            index++
        }
        // now we get the next 3 digits and format them
        if (length - index > 3) {
            var areaCode = decimalString.substringWithRange(NSMakeRange(index, 3)) as String
            formattedString += "(\(areaCode)) "
            index += 3
        }
        // now we get the *next* three and format them
        if (length - index > 3) {
            var prefix = decimalString.substringWithRange(NSMakeRange(index, 3)) as String
            formattedString += "\(prefix)-"
            index += 3
        }
        // add on the rest of the digits
        var remainder = decimalString.substringFromIndex(index) as String
        formattedString += remainder
        textField.text = formattedString

        // we set it manually, so don't change
        return false
    }

    // Check the phone number is valid
    func verifyPhone() -> Bool {

        // get the decimals as a string
        phoneNumber = phoneTextField.text
        var components: NSArray = phoneNumber.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        var decimalString: NSString = components.componentsJoinedByString("")

        var hasLeadingOne: Bool = (decimalString.length > 0) && (decimalString.substringToIndex(1) == "1")

        if (decimalString.length < 10 || decimalString.length > 11 || (decimalString.length == 10 && hasLeadingOne)) {

            return false
        }

        return true
    }

    // Show the main vc after getting a uid
    func showMainView() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewControllerWithIdentifier("MainNavController") as! UINavigationController

        self.presentViewController(mainVC, animated: true, completion: nil)
    }
}