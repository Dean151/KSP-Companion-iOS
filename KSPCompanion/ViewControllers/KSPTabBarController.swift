//
//  KSPTabBarController.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 25/09/2015.
//  Copyright © 2015 Thomas Durand. All rights reserved.
//

import UIKit

class KSPTabBarController: UITabBarController {
    
    var selectedItem: UITabBarItem?
    var vcReplaced = false
    
    var _shoudShow = 0
    var shouldShow: Int {
        get {
            return _shoudShow
        }
        set {
            _shoudShow = newValue
            if newValue != self.selectedIndex && vcReplaced {
                self.setIndex(newValue)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var newViewControllers = [BannerViewController]()
        
        self.viewControllers!.forEach { vc in
            vc.title = NSLocalizedString(vc.title!, comment: "")
            let bvc = BannerViewController(contentController: vc)
            bvc.tabBarItem = vc.tabBarItem
            newViewControllers.append(bvc)
        }
        
        self.setViewControllers(newViewControllers, animated: false)
        self.vcReplaced = true
        
        self.setIndex(shouldShow)
    }
    
    func setIndex(index: Int) {
        guard index < self.viewControllers!.count else { return }
        self.selectedIndex = index
        self.selectedItem = self.viewControllers![index].tabBarItem
    }
    
    override func restoreUserActivityState(activity: NSUserActivity) {
        self.viewControllers?.forEach({
            $0.restoreUserActivityState(activity)
        })
        super.restoreUserActivityState(activity)
    }
    
    // MARK: UITabBarControllerDelegate
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if self.selectedItem == item {
            // Here we tapped again a selected item
            // So we should go back on one step
            guard let bannerVC = self.selectedViewController as? BannerViewController else { return }
            (bannerVC.contentController as? KSPSplitViewController)?.rollBack()
        } else {
            self.selectedItem = item
        }
    }
}
