//
//  CelestialsTableViewController.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 30/05/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import UIKit
import HexColors

class CelestialsTableViewController: UITableViewController {
    
    let reusableCellIdentifier = "CelestialCell"
    var celestials = [Celestial]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(hexString: "#2E2E2E")
        
        self.navigationController?.topViewController!.title = NSLocalizedString("CELESTIALS", comment: "")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), style: .Plain, target: self, action: "openSolarSystemSelector:")
        
        // Peek and Pop
        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .Available {
                registerForPreviewingWithDelegate(self, sourceView: view)
            }
        }
    }
    
    func loadCelestials() {
        let newData = DataManager.getCelestialsFromJson()
        if celestials.count != newData.count {
            celestials = newData
            self.tableView.beginUpdates()
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
            self.tableView.endUpdates()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        
        super.viewWillAppear(animated)
        
        // refreshing data
        loadCelestials()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewCelestialDetails" {
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! CelestialViewController
            
            if let index = tableView.indexPathForSelectedRow {
                controller.prepare(celestial: celestials[index.row])
            }
        }
    }
    
    func openSolarSystemSelector(sender: UIBarButtonItem) {
        let viewController = SolarSystemSelector()
        viewController.parentController = self
        let navController = UINavigationController(rootViewController: viewController)
        
        if (UI_USER_INTERFACE_IDIOM() == .Pad) {
            let popover = UIPopoverController(contentViewController: navController)
            popover.presentPopoverFromBarButtonItem(sender, permittedArrowDirections: .Any, animated: true)
        } else {
            self.presentViewController(navController, animated: true, completion: nil)
        }
    }
    
    // MARK: TableView DataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return celestials.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reusableCellIdentifier, forIndexPath: indexPath) 
        
        let row = indexPath.row
        let celestial = celestials[row]
        
        configureCell(cell, celestial: celestial)
        
        return cell
    }
    
    func configureCell(cell: UITableViewCell, celestial: Celestial) {
        cell.textLabel?.text = celestial.name
        
        // Setting colors
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.textColor = celestial.color
        cell.imageView?.tintColor = celestial.color
        cell.textLabel?.highlightedTextColor = UIColor.blackColor();
        
        cell.accessoryType = self.splitViewController!.collapsed ? .DisclosureIndicator : .None;
        
        //cell.indentationLevel = celestial.indentation
        
        if let img = celestial.type.image {
            cell.imageView?.image = img.imageWithRenderingMode(.AlwaysTemplate)
        } else {
            cell.imageView?.image = nil
        }
    }
    
    // MARK: TableView custom actions
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let celestial = celestials[indexPath.row]
        guard let orbit = celestial.orbit else { return false }
        return orbit.eccentricity < 0.3
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        // From action
        let fromAction = UITableViewRowAction(style: .Default, title: NSLocalizedString("LEAVE", comment: "") , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            self.setFromAtIndexPath(indexPath)
        })
        // To action
        let toAction = UITableViewRowAction(style: .Default, title: NSLocalizedString("GO_TO", comment: "") , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            self.setToAtIndexPath(indexPath)
        })
        
        // Custom colors
        fromAction.backgroundColor = UIColor(hexString: "#a4a4a4")
        toAction.backgroundColor = UIColor(hexString: "#868686")
        
        return [toAction,fromAction]
    }
    
    func setFromAtIndexPath(indexPath: NSIndexPath) {
        self.setFromOrTo(true, atIndexPath: indexPath)
    }
    
    func setToAtIndexPath(indexPath: NSIndexPath) {
        self.setFromOrTo(false, atIndexPath: indexPath)
    }
    
    func setFromOrTo(from: Bool, atIndexPath indexPath: NSIndexPath) {
        self.performSelector("closeEditActions", withObject: nil, afterDelay: 0.1)
        // Looking for the right controller
        guard let tabBarController = self.tabBarController as? KSPTabBarController else { print("No Tab Bar"); return }
        guard let bannerVC = tabBarController.viewControllers?[1] as? BannerViewController else { print("No Banner view controller"); return }
        guard let splitVC = bannerVC.contentController as? KSPSplitViewController else { print("No Split view controller"); return }
        guard let navVC = splitVC.viewControllers.first as? UINavigationController else { print("No nav controller"); return }
        guard let transferVC = navVC.viewControllers.first as? TransferFormViewController else { print("No tranfer controller"); return }
        
        // We reload celestial in the case the system was changed just before using a shortcut
        transferVC.loadCelestials()
        
        // Setting the destination
        let celestial = celestials[indexPath.row]
        if from {
            transferVC.form.setValues(["from": celestial])
        } else {
            transferVC.form.setValues(["to": celestial])
        }
        
        // Reloading the table
        transferVC.tableView!.reloadData()
        
        // Changing the view
        tabBarController.shouldShow = 1
    }
    
    func closeEditActions() {
        self.tableView.setEditing(false, animated: true)
    }
}

@available(iOS 9.0, *)
extension CelestialsTableViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        // Getting celestial
        guard let indexPath = self.tableView.indexPathForRowAtPoint(location), cell = tableView.cellForRowAtIndexPath(indexPath) else { return nil }
        
        // Creating viewController
        guard let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("CelestialViewController") as? CelestialViewController else { return nil }
        
        // Param controller
        viewController.preferredContentSize = CGSize(width: 0, height: 0)
        viewController.prepare(celestial: self.celestials[indexPath.row])
        
        // Context source rect for bluring the right place
        previewingContext.sourceRect = cell.frame
        
        return viewController
    }
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        showViewController(viewControllerToCommit, sender: self)
    }
}