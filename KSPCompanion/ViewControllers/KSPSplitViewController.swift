//
//  KSPSplitViewController.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 22/09/2015.
//  Copyright © 2015 Thomas Durand. All rights reserved.
//

import UIKit

class KSPSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.preferredDisplayMode = .AllVisible
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sizeChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.viewControllers.forEach { vc in
            vc.viewWillAppear(animated)
        }
        
        super.viewWillAppear(animated)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.sizeChanged(self)
    }
    
    func splitViewController(splitViewController: UISplitViewController,
        collapseSecondaryViewController secondaryViewController: UIViewController,
        ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return true
    }
    
    func sizeChanged(sender: AnyObject) {
        guard let navVC = self.viewControllers.first as? UINavigationController else { return }
        guard let masterVC = navVC.topViewController as? CelestialsTableViewController else { return }
        masterVC.tableView.reloadData()
    }
    
    func rollBack() {
        if self.collapsed {
            guard let navVC = self.viewControllers.last as? UINavigationController else { return }
            navVC.popToRootViewControllerAnimated(true)
        }
    }
}

extension UINavigationController {
    override public func viewWillAppear(animated: Bool) {
        self.viewControllers.forEach { vc in
            vc.viewWillAppear(animated)
        }
        
        super.viewWillAppear(animated)
    }
}