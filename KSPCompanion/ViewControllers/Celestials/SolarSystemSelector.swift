//
//  SolarSystemSelector.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 23/09/2015.
//  Copyright © 2015 Thomas Durand. All rights reserved.
//

import UIKit

class SolarSystemSelector: UITableViewController {
    
    var parentController: CelestialsTableViewController?
    
    init () {
        super.init(style: .Grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add title to navbar
        self.navigationItem.title = NSLocalizedString("SYSTEMS", comment: "")
        
        // Constraint for popover view
        self.preferredContentSize = CGSizeMake(320, 130 + 44*CGFloat(SolarSystem.count))
        
        // Adding button to dismiss view
        let dismissButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: Selector("dismiss:"))
        self.navigationItem.rightBarButtonItem = dismissButton;
    }
    
    override func viewWillDisappear(animated: Bool) {
        if let parent = self.parentController {
            parent.loadCelestials()
        }
    }
    
    func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Mark: TableView
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SolarSystem.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
        
        if let solarSystem = SolarSystem(rawValue: indexPath.row) {
            cell.textLabel?.text = "\(solarSystem)"
            if solarSystem == Settings.sharedInstance.solarSystem {
                cell.accessoryType = .Checkmark
            } else {
                cell.accessoryType = .None
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let solarSystem = SolarSystem(rawValue: indexPath.row) {
            Settings.sharedInstance.solarSystem = solarSystem
            self.dismiss(self)
        }
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return NSLocalizedString("SYSTEM_SELECTION_DESCRIPTION", comment: "")
    }
}