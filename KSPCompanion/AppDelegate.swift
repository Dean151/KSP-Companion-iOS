//
//  AppDelegate.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 22/09/2015.
//  Copyright © 2015 Thomas Durand. All rights reserved.
//

import UIKit
import iRate
import Fabric
import Crashlytics

enum HandoffIdentifier: String {
    case Celestials, Celestial
    
    init?(fullType: String) {
        guard let last = fullType.componentsSeparatedByString(".").last else { return nil }
        self.init(rawValue: last)
    }
    
    var type: String {
        return NSBundle.mainBundle().bundleIdentifier! + ".\(self.rawValue)"
    }
    
    var tabNumber: Int {
        switch self {
        case .Celestials, .Celestial:
            return 0
        }
    }
}

enum ShortcutIdentifier: String {
    case Celestials, Transfer, Distribution
    
    init?(fullType: String) {
        guard let last = fullType.componentsSeparatedByString(".").last else { return nil }
        self.init(rawValue: last)
    }
    
    var type: String {
        return NSBundle.mainBundle().bundleIdentifier! + ".\(self.rawValue)"
    }
    
    var tabNumber: Int {
        switch self {
        case .Celestials:
            return 0
        case .Transfer:
            return 1
        case .Distribution:
            return 2
        }
    }
}

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
        var isLaunchedFromQuickAction = false
        
        if let window = self.window {
            window.tintColor = UIColor.appGreenColor
        }
        
        // White status bar
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // NavigationBar style
        UINavigationBar.appearance().barStyle = .Black
        UINavigationBar.appearance().translucent = false
        
        // TabBar style
        UITabBar.appearance().barStyle = .Black
        UITabBar.appearance().translucent = false
        
        Fabric.with([Crashlytics.self()])
        
        if #available(iOS 9.0, *) {
            if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
                // Handle the sortcutItem
                guard let shortcutType = ShortcutIdentifier(fullType: shortcutItem.type) else { return false }
                isLaunchedFromQuickAction = true
                handleQuickAction(shortcutType)
            }
        }
        
        return !isLaunchedFromQuickAction
    }
    
    // MARK: - Handoff
    
    func application(application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        return true
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        var handled = false
        
        guard let userInfo = userActivity.userInfo else { return false }
        print("Received a payload via handoff: \(userInfo)")
        
        if let handoffId = HandoffIdentifier.init(fullType: userActivity.activityType) {
            guard let tabbar = self.window?.rootViewController as? KSPTabBarController else { return false }
            tabbar.shouldShow = handoffId.tabNumber
            tabbar.restoreUserActivityState(userActivity)
            handled = true
        }
        
        return handled
    }
    
    func application(application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: NSError) {
        if error.code != NSUserCancelledError {
            print("Handoff error occured")
        } else {
            print("Handoff cancelled")
        }
    }
    
    // Mark: - 3DTouch Shortcuts
    
    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        
        // Handle quick actions
        guard let shortcutType = ShortcutIdentifier(fullType: shortcutItem.type) else { return }
        completionHandler(handleQuickAction(shortcutType))
    }
    
    @available(iOS 9.0, *)
    func handleQuickAction(shortcutType: ShortcutIdentifier) -> Bool {
        guard let tabbar = self.window?.rootViewController as? KSPTabBarController else { return false }
        tabbar.shouldShow = shortcutType.tabNumber
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

extension UIColor {
    static var appGreenColor: UIColor {
        return UIColor(red: 16/255, green: 149/255, blue: 0, alpha: 1)
    }
}
