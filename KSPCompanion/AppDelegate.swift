//
//  AppDelegate.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 22/09/2015.
//  Copyright © 2015 Thomas Durand. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

enum HandoffIdentifier: String {
    case Celestials, Celestial
    
    init?(fullType: String) {
        guard let last = fullType.components(separatedBy: ".").last else { return nil }
        self.init(rawValue: last)
    }
    
    var type: String {
        return Bundle.main.bundleIdentifier! + ".\(self.rawValue)"
    }
    
    var tabNumber: Int {
        switch self {
        case .Celestials, .Celestial:
            return 0
        }
    }
}

enum ShortcutIdentifier: String {
    case Celestials, Transfer, Distribution, Settings
    
    init?(fullType: String) {
        guard let last = fullType.components(separatedBy: ".").last else { return nil }
        self.init(rawValue: last)
    }
    
    var type: String {
        return Bundle.main.bundleIdentifier! + ".\(self.rawValue)"
    }
    
    var tabNumber: Int {
        switch self {
        case .Celestials:
            return 0
        case .Transfer:
            return 1
        case .Distribution:
            return 2
        case .Settings:
            return 3
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        var isLaunchedFromQuickAction = false
        
        if let window = self.window {
            window.tintColor = UIColor.appGreenColor
        }
        
        // White status bar
        UIApplication.shared.statusBarStyle = .lightContent
        
        // NavigationBar style
        UINavigationBar.appearance().barStyle = .black
        UINavigationBar.appearance().isTranslucent = false
        
        // TabBar style
        UITabBar.appearance().barStyle = .black
        UITabBar.appearance().isTranslucent = false
        
        Fabric.with([Crashlytics.self()])
        
        if #available(iOS 9.0, *) {
            if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
                // Handle the sortcutItem
                guard let shortcutType = ShortcutIdentifier(fullType: shortcutItem.type) else { return false }
                isLaunchedFromQuickAction = true
                _ = handleQuickAction(shortcutType)
            }
        }
        
        return !isLaunchedFromQuickAction
    }
    
    // Mark: - 3DTouch Shortcuts
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        // Handle quick actions
        guard let shortcutType = ShortcutIdentifier(fullType: shortcutItem.type) else { return }
        completionHandler(handleQuickAction(shortcutType))
    }
    
    func handleQuickAction(_ shortcutType: ShortcutIdentifier) -> Bool {
        guard let tabbar = self.window?.rootViewController as? KSPTabBarController else { return false }
        tabbar.shouldShow = shortcutType.tabNumber
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension UIColor {
    static var appGreenColor: UIColor {
        return UIColor(red: 16/255, green: 149/255, blue: 0, alpha: 1)
    }
}
