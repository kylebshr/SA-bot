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
        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)

        Parse.setApplicationId("REDACTED", clientKey: "REDACTED")


        let notificationTypes: UIUserNotificationType = (UIUserNotificationType.Alert |
            UIUserNotificationType.Badge |
            UIUserNotificationType.Sound)
        let settings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()

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

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {

        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.channels = ["global"]
        installation.saveInBackgroundWithBlock(nil)
    }
}