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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.delegate = self
        
        var newViewControllers = [BannerViewController]()
        
        self.viewControllers!.forEach { vc in
            vc.title = NSLocalizedString(vc.title!, comment: "")
            let bvc = BannerViewController(contentController: vc)
            bvc.tabBarItem = vc.tabBarItem
            newViewControllers.append(bvc)
        }
        
        self.setViewControllers(newViewControllers, animated: false)
        self.selectedItem = newViewControllers[0].tabBarItem
    }
    
    func changeToIndex(index: Int) {
        self.selectedItem = self.viewControllers![index].tabBarItem
        self.selectedIndex = index
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
