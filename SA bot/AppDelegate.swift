//
//  AppDelegate.swift
//  SA bot
//
//  Created by Kyle Bashour on 2/27/15.
//
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        Parse.enableLocalDatastore()

        var defaultACL = PFACL()
        // Optionally enable public read access while disabling public write access.
        // defaultACL.setPublicReadAccess(true)
        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)

        Parse.setApplicationId("REDACTED", clientKey: "REDACTED")

        // Check if they have a UID and if not, present the sign up screen
        if PFUser.currentUser() == nil {

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let signUpVC = storyboard.instantiateViewControllerWithIdentifier("WelcomeNavController") as! UINavigationController

            window = UIWindow(frame: UIScreen.mainScreen().bounds)
            window?.rootViewController = signUpVC
            window?.makeKeyAndVisible()
        }

        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)

        return true
    }
}