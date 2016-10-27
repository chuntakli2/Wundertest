//
//  AppDelegate.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if (ProcessInfo.processInfo.environment["animations"] == "0") {
            UIView.setAnimationsEnabled(false)
        }
        
        let navigationBarBackground = UIImage.image(withColour: NAVIGATION_BAR_COLOUR)
        let appearance = UINavigationBar.appearance()
        appearance.setBackgroundImage(navigationBarBackground, for: .default)
        appearance.tintColor = .white
        appearance.titleTextAttributes = FONT_ATTR_LARGE_WHITE_BOLD
        
        let taskViewController = TaskViewController()
        taskViewController.title = "Wundertest"
        let taskNavigationController = BaseNavigationController(rootViewController: taskViewController)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = .white
        self.window?.tintColor = TINT_COLOUR
        self.window?.rootViewController = taskNavigationController
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let type = shortcutItem.type
        if (type.contains("createTask")) {
            let taskNavigationController = self.window?.rootViewController as! BaseNavigationController
            taskNavigationController.popToRootViewController(animated: false)
            let taskViewController = taskNavigationController.viewControllers.first as! TaskViewController
            taskViewController.composeTask()
        }
    }
}

