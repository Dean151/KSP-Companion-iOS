//
//  AppDelegate.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 22/09/2015.
//  Copyright © 2015 Thomas Durand. All rights reserved.
//

import UIKit
import iRate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    override init() {
        // Giving manually this data allow to make quick access to iTunes data
        iRate.sharedInstance().appStoreID = 1004723358
        iRate.sharedInstance().applicationName = "KSP Companion"
        iRate.sharedInstance().verboseLogging = false
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        if let window = self.window {
            window.tintColor = UIColor(red: 16/255, green: 149/255, blue: 0, alpha: 1)
        }
        
        // White status bar
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // NavigationBar style
        UINavigationBar.appearance().barStyle = .Black
        UINavigationBar.appearance().translucent = false
        
        // TabBar style
        UITabBar.appearance().barStyle = .Black
        UITabBar.appearance().translucent = false
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

