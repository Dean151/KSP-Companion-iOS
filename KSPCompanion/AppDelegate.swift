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
    
    enum ShortcutIdentifier: String {
        case celestials
        case tranfer
        case distribute
        
        init?(fullType: String) {
            guard let last = fullType.componentsSeparatedByString(".").last else { return nil }
            
            self.init(rawValue: last)
        }
        
        var type: String {
            return NSBundle.mainBundle().bundleIdentifier! + ".\(self.rawValue)"
        }
    }

    var window: UIWindow?
    
    override init() {
        // Giving manually this data allow to make quick access to iTunes data
        iRate.sharedInstance().appStoreID = 1004723358
        iRate.sharedInstance().applicationName = "KSP Companion"
        iRate.sharedInstance().verboseLogging = false
    }
    
    @available(iOS 9.0, *)
    func handleShortCutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
        var handled = false
        
        guard let shortcutType = shortcutItem.type as String? else { return false }
        guard let window = self.window else { return false }
        
        switch shortcutType {
        case ShortcutIdentifier.celestials.type:
            (window.rootViewController as! UITabBarController).selectedIndex = 0
            handled = true
        case ShortcutIdentifier.tranfer.type:
            (window.rootViewController as! UITabBarController).selectedIndex = 1
            handled = true
        case ShortcutIdentifier.distribute.type:
            (window.rootViewController as! UITabBarController).selectedIndex = 2
            handled = true
        default:
            break
        }
        
        return handled
    }
    
    /*
    Called when the user activates your application by selecting a shortcut on the home screen, except when
    application(_:,willFinishLaunchingWithOptions:) or application(_:didFinishLaunchingWithOptions) returns `false`.
    You should handle the shortcut in those callbacks and return `false` if possible. In that case, this
    callback is used if your application is already launched in the background.
    */
    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        let handledShortCutItem = handleShortCutItem(shortcutItem)
        completionHandler(handledShortCutItem)
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
        
         var shouldPerformAdditionalDelegateHandling = true
        
        if #available(iOS 9.0, *) {
            if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
                
                handleShortCutItem(shortcutItem)
                
                // This will block "performActionForShortcutItem:completionHandler" from being called.
                shouldPerformAdditionalDelegateHandling = false
            }
        }
        
        return shouldPerformAdditionalDelegateHandling
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
