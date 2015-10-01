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
        
        // 3DTouch
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
            self.tableView.reloadData()
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
        
        if let img = celestial.type.image {
            cell.imageView?.image = img.imageWithRenderingMode(.AlwaysTemplate)
        } else {
            cell.imageView?.image = nil
        }
    }
}

// Peek and Pop
@available(iOS 9.0, *)
extension CelestialsTableViewController: UIViewControllerPreviewingDelegate {
    
    // Peek
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRowAtPoint(location),
            cell = tableView.cellForRowAtIndexPath(indexPath) else { return nil }
        
        // Instanciating the view
        guard let navViewController = storyboard?.instantiateViewControllerWithIdentifier("CelestialNavController") as? UINavigationController else { print("no celestialnavcontroller"); return nil }
        guard let detailViewController = navViewController.topViewController as? CelestialViewController else { print("no celestialdetailcontroler"); return nil }
        
        // Parametring the view controller
        detailViewController.prepare(celestial: celestials[indexPath.row])
        
        // Set the default size for the preview
        detailViewController.preferredContentSize = CGSize(width: 0.0, height: 0.0)
        
        // Allow bluring the right place
        previewingContext.sourceRect = cell.frame
        
        return detailViewController
    }
    
    // Pop
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        showViewController(viewControllerToCommit, sender: self)
    }
}