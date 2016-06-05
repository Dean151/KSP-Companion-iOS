//
//  CelestialsTableViewController.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 30/05/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import UIKit
import HexColors

class CelestialsTableViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating {
    
    let reusableCellIdentifier = "CelestialCell"
    var celestials: [Celestial] = []
    
    // Research
    var searchController:UISearchController!
    var searchResults:[Celestial] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hexString: "#2E2E2E")
        tableView.backgroundColor = UIColor(hexString: "#2E2E2E")
        
        self.navigationController?.topViewController!.title = NSLocalizedString("CELESTIALS", comment: "")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), style: .Plain, target: self, action: #selector(CelestialsTableViewController.openSolarSystemSelector(_:)))
        
        // Research
        searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        
        // Searchbar customization
        searchController.searchBar.barTintColor = UIColor.blackColor()
        searchController.searchBar.backgroundImage = UIImage()
        
        
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
            searchResults = []
            celestials = newData
            self.tableView.beginUpdates()
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
            self.tableView.endUpdates()
            
            self.userActivity?.needsSave = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        rz_smoothlyDeselectRows(tableView: self.tableView)
        
        // refreshing data
        loadCelestials()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewCelestialDetails" {
            //stopUserActivity()
            
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! CelestialViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let celestial = getCelestialAtIndexPath(indexPath)
                controller.prepare(celestial: celestial)
            }
        }
    }
    
    // MARK: Research feature
    
    var isResearching: Bool {
        guard let searchText = searchController.searchBar.text else { return false }
        return searchController.active && !searchText.isEmpty
    }
    
    func filterContentForSearchText(searchText: String) {
        searchResults = self.celestials.filter({ ( cel: Celestial) -> Bool in
            let nameMatch = cel.name.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return nameMatch != nil
            })
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filterContentForSearchText(searchText)
        tableView.reloadData()
    }
    
    func willPresentSearchController(searchController: UISearchController) {
        self.navigationItem.rightBarButtonItem?.enabled = false
    }
    
    func willDismissSearchController(searchController: UISearchController) {
        self.navigationItem.rightBarButtonItem?.enabled = true
    }
    
    // MARK: Other solar systems
    
    func openSolarSystemSelector(sender: UIBarButtonItem) {
        let viewController = SolarSystemSelector()
        
        guard !searchController.active else { return }
        
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
        return self.isResearching ? searchResults.count :celestials.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reusableCellIdentifier, forIndexPath: indexPath) 
        
        let celestial = getCelestialAtIndexPath(indexPath)
        
        configureCell(cell, celestial: celestial)
        
        return cell
    }
    
    func getCelestialAtIndexPath(indexPath: NSIndexPath) -> Celestial {
        return self.isResearching ? searchResults[indexPath.row] : celestials[indexPath.row]
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
            cell.imageView?.highlightedImage = img.imageWithRenderingMode(.AlwaysOriginal)
        } else {
            cell.imageView?.image = nil
        }
    }
    
    // MARK: TableView custom actions
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let celestial = getCelestialAtIndexPath(indexPath)
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
        self.performSelector(#selector(CelestialsTableViewController.closeEditActions), withObject: nil, afterDelay: 0.1)
        // Looking for the right controller
        guard let tabBarController = self.tabBarController as? KSPTabBarController else { print("No Tab Bar"); return }
        guard let splitVC = tabBarController.viewControllers?[1] as? KSPSplitViewController else { print("No Split view controller"); return }
        guard let navVC = splitVC.viewControllers.first as? UINavigationController else { print("No nav controller"); return }
        guard let transferVC = navVC.viewControllers.first as? TransferFormViewController else { print("No tranfer controller"); return }
        
        // We reload celestial in the case the system was changed just before using a shortcut
        transferVC.loadCelestials()
        
        // Setting the destination
        let celestial = getCelestialAtIndexPath(indexPath)
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

// MARK: - Peek & Pop

@available(iOS 9.0, *)
extension CelestialsTableViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        // Getting celestial
        guard let indexPath = self.tableView.indexPathForRowAtPoint(location), cell = tableView.cellForRowAtIndexPath(indexPath) else { return nil }
        
        // Creating viewController
        guard let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("CelestialViewController") as? CelestialViewController else { return nil }
        
        // Param controller
        viewController.preferredContentSize = CGSize(width: 0, height: 0)
        viewController.prepare(celestial: getCelestialAtIndexPath(indexPath))
        
        // Context source rect for bluring the right place
        previewingContext.sourceRect = cell.frame
        
        return viewController
    }
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        showViewController(viewControllerToCommit, sender: self)
    }
}

extension UIViewController {
    
    ///  Smoothly deselect selected rows in a table view during an animated
    ///  transition, and intelligently reselect those rows if the interactive
    ///  transition is canceled. Call this method from inside your view
    ///  controller's `viewWillAppear(_:)` method.
    ///
    ///  - parameter tableView: The table view in which to perform deselection/reselection.
    func rz_smoothlyDeselectRows(tableView tableView: UITableView?) {
        let selectedIndexPaths = tableView?.indexPathsForSelectedRows ?? []
        
        if let coordinator = transitionCoordinator() {
            coordinator.animateAlongsideTransitionInView(parentViewController?.view, animation: { context in
                selectedIndexPaths.forEach {
                    tableView?.deselectRowAtIndexPath($0, animated: context.isAnimated())
                }
                }, completion: { context in
                    if context.isCancelled() {
                        selectedIndexPaths.forEach {
                            tableView?.selectRowAtIndexPath($0, animated: false, scrollPosition: .None)
                        }
                    }
            })
        }
        else {
            selectedIndexPaths.forEach {
                tableView?.deselectRowAtIndexPath($0, animated: false)
            }
        }
    }
}
