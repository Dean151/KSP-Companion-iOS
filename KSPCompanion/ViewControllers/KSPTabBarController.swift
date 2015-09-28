//
//  KSPTabBarController.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 25/09/2015.
//  Copyright © 2015 Thomas Durand. All rights reserved.
//

import UIKit

class KSPTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var newViewControllers = [UIViewController]()
        
        self.viewControllers!.forEach { vc in
            vc.title = NSLocalizedString(vc.title!, comment: "")
            let bvc = BannerViewController(contentController: vc)
            bvc.tabBarItem = vc.tabBarItem
            newViewControllers.append(bvc)
        }
        
        self.setViewControllers(newViewControllers, animated: false)
    }
}
