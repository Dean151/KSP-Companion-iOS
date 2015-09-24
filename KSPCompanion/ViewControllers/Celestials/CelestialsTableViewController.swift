//
//  CelestialsTableViewController.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 30/05/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import UIKit
import HexColors

class CelestialsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let reusableCellIdentifier = "CelestialCell"
    var celestials = [Celestial]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(hexString: "#2E2E2E")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationController?.topViewController!.title = NSLocalizedString("CELESTIALS", comment: "")
    }
    
    func loadCelestials() {
        let newData = DataManager.getCelestialsFromJson()
        if celestials.count != newData.count {
            celestials = newData
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // refreshing data
        loadCelestials()
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPath, animated: animated)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewCelestialDetails" {
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! CelestialViewController
            
            if let index = tableView.indexPathForSelectedRow {
                controller.prepare(celestial: celestials[index.row])
            }
        }
    }
    
    @IBAction func openSolarSystemSelector(sender: UIBarButtonItem) {
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return celestials.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reusableCellIdentifier, forIndexPath: indexPath) 
        
        let row = indexPath.row
        cell.textLabel?.text = celestials[row].name
        
        // Setting colors
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.textColor = celestials[row].color
        cell.imageView?.tintColor = celestials[row].color
        cell.textLabel?.highlightedTextColor = UIColor.blackColor();
        
        if UI_USER_INTERFACE_IDIOM() == .Pad {
            cell.accessoryType = .None
        }
        
        if let img = celestials[row].type.image {
            cell.imageView?.image = img.imageWithRenderingMode(.AlwaysTemplate)
        }
        
        return cell
    }
}