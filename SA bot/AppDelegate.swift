//
//  AppDelegate.swift
//  SA bot
//
//  Created by Kyle Bashour on 2/27/15.
//
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        // Check if they have a UID and if not, present the sign up screen
        if NSUserDefaults.standardUserDefaults().stringForKey("uid") == nil {

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let signUpVC = storyboard.instantiateViewControllerWithIdentifier("WelcomeNavController") as! UINavigationController

            window = UIWindow(frame: UIScreen.mainScreen().bounds)
            window?.rootViewController = signUpVC
            window?.makeKeyAndVisible()
        }

        return true
    }
}