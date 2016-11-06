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
    
    var _shoudShow = 0
    var shouldShow: Int {
        get {
            return _shoudShow
        }
        set {
            _shoudShow = newValue
            if newValue != self.selectedIndex {
                self.setIndex(newValue)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setIndex(shouldShow)
    }
    
    func setIndex(_ index: Int) {
        guard index < self.viewControllers!.count else { return }
        self.selectedIndex = index
        self.selectedItem = self.viewControllers![index].tabBarItem
    }
    
    override func restoreUserActivityState(_ activity: NSUserActivity) {
        self.viewControllers?.forEach({
            $0.restoreUserActivityState(activity)
        })
        super.restoreUserActivityState(activity)
    }
    
    // MARK: UITabBarControllerDelegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if self.selectedItem == item {
            // Here we tapped again a selected item
            // So we should go back on one step
            guard let splitVC = self.selectedViewController as? KSPSplitViewController else { return }
            splitVC.rollBack()
        } else {
            self.selectedItem = item
        }
    }
}
