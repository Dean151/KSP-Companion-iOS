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
        self.preferredDisplayMode = .allVisible
        
        NotificationCenter.default.addObserver(self, selector: #selector(KSPSplitViewController.sizeChanged(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewControllers.forEach { vc in
            vc.viewWillAppear(animated)
        }
        
        super.viewWillAppear(animated)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.sizeChanged(self)
    }
    
    func splitViewController(_ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
    func sizeChanged(_ sender: AnyObject) {
        guard let navVC = self.viewControllers.first as? UINavigationController else { return }
        guard let masterVC = navVC.topViewController as? CelestialsTableViewController else { return }
        masterVC.tableView.reloadData()
    }
    
    func rollBack() {
        if self.isCollapsed {
            guard let navVC = self.viewControllers.last as? UINavigationController else { return }
            navVC.popToRootViewController(animated: true)
        }
    }
    
    override func restoreUserActivityState(_ activity: NSUserActivity) {
        self.viewControllers.forEach({
            $0.restoreUserActivityState(activity)
        })
        super.restoreUserActivityState(activity)
    }
}

extension UINavigationController {
    override open func viewWillAppear(_ animated: Bool) {
        self.viewControllers.forEach { vc in
            vc.viewWillAppear(animated)
        }
        
        super.viewWillAppear(animated)
    }
    
    override open func restoreUserActivityState(_ activity: NSUserActivity) {
        self.viewControllers.forEach({
            $0.restoreUserActivityState(activity)
        })
        super.restoreUserActivityState(activity)
    }
}
