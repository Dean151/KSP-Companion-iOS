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
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: self, action: #selector(CelestialsTableViewController.openSolarSystemSelector(_:)))
        
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
        searchController.searchBar.barTintColor = UIColor.black
        searchController.searchBar.backgroundImage = UIImage()
        
        
        // Peek and Pop
        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .available {
                registerForPreviewing(with: self, sourceView: view)
            }
        }
    }
    
    func loadCelestials() {
        let newData = DataManager.getCelestialsFromJson()
        if celestials.count != newData.count {
            searchResults = []
            celestials = newData
            self.tableView.beginUpdates()
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            self.tableView.endUpdates()
            
            self.userActivity?.needsSave = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        rz_smoothlyDeselectRows(tableView: self.tableView)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        // refreshing data
        loadCelestials()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewCelestialDetails" {
            //stopUserActivity()
            
            let controller = (segue.destination as! UINavigationController).topViewController as! CelestialViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let celestial = getCelestialAtIndexPath(indexPath)
                controller.prepare(celestial: celestial)
            }
        }
    }
    
    // MARK: Research feature
    
    var isResearching: Bool {
        guard let searchText = searchController.searchBar.text else { return false }
        return searchController.isActive && !searchText.isEmpty
    }
    
    func filterContentForSearchText(_ searchText: String) {
        searchResults = self.celestials.filter({ ( cel: Celestial) -> Bool in
            let nameMatch = cel.name.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return nameMatch != nil
            })
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filterContentForSearchText(searchText)
        tableView.reloadData()
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    // MARK: Other solar systems
    
    func openSolarSystemSelector(_ sender: UIBarButtonItem) {
        let viewController = SolarSystemSelector()
        
        guard !searchController.isActive else { return }
        
        viewController.parentController = self
        let navController = UINavigationController(rootViewController: viewController)
        
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            let popover = UIPopoverController(contentViewController: navController)
            popover.present(from: sender, permittedArrowDirections: .any, animated: true)
        } else {
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    // MARK: TableView DataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isResearching ? searchResults.count :celestials.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reusableCellIdentifier, for: indexPath) 
        
        let celestial = getCelestialAtIndexPath(indexPath)
        
        configureCell(cell, celestial: celestial)
        
        return cell
    }
    
    func getCelestialAtIndexPath(_ indexPath: IndexPath) -> Celestial {
        return self.isResearching ? searchResults[indexPath.row] : celestials[indexPath.row]
    }
    
    func configureCell(_ cell: UITableViewCell, celestial: Celestial) {
        cell.textLabel?.text = celestial.name
        
        // Setting colors
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = celestial.color
        cell.imageView?.tintColor = celestial.color
        cell.textLabel?.highlightedTextColor = UIColor.black;
        
        cell.accessoryType = self.splitViewController!.isCollapsed ? .disclosureIndicator : .none;
        
        //cell.indentationLevel = celestial.indentation
        
        if let img = celestial.type.image {
            cell.imageView?.image = img.withRenderingMode(.alwaysTemplate)
            cell.imageView?.highlightedImage = img.withRenderingMode(.alwaysOriginal)
        } else {
            cell.imageView?.image = nil
        }
    }
    
    // MARK: TableView custom actions
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let celestial = getCelestialAtIndexPath(indexPath)
        guard let orbit = celestial.orbit else { return false }
        return orbit.eccentricity < 0.3
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // From action
        let fromAction = UITableViewRowAction(style: .default, title: NSLocalizedString("LEAVE", comment: "") , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            self.setFromAtIndexPath(indexPath)
        })
        // To action
        let toAction = UITableViewRowAction(style: .default, title: NSLocalizedString("GO_TO", comment: "") , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            self.setToAtIndexPath(indexPath)
        })
        
        // Custom colors
        fromAction.backgroundColor = UIColor(hexString: "#a4a4a4")
        toAction.backgroundColor = UIColor(hexString: "#868686")
        
        return [toAction,fromAction]
    }
    
    func setFromAtIndexPath(_ indexPath: IndexPath) {
        self.setFromOrTo(true, atIndexPath: indexPath)
    }
    
    func setToAtIndexPath(_ indexPath: IndexPath) {
        self.setFromOrTo(false, atIndexPath: indexPath)
    }
    
    func setFromOrTo(_ from: Bool, atIndexPath indexPath: IndexPath) {
        self.perform(#selector(CelestialsTableViewController.closeEditActions), with: nil, afterDelay: 0.1)
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
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        // Getting celestial
        guard let indexPath = self.tableView.indexPathForRow(at: location), let cell = tableView.cellForRow(at: indexPath) else { return nil }
        
        // Creating viewController
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CelestialViewController") as? CelestialViewController else { return nil }
        
        // Param controller
        viewController.preferredContentSize = CGSize(width: 0, height: 0)
        viewController.prepare(celestial: getCelestialAtIndexPath(indexPath))
        
        // Context source rect for bluring the right place
        previewingContext.sourceRect = cell.frame
        
        return viewController
    }
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}

extension UIViewController {
    
    ///  Smoothly deselect selected rows in a table view during an animated
    ///  transition, and intelligently reselect those rows if the interactive
    ///  transition is canceled. Call this method from inside your view
    ///  controller's `viewWillAppear(_:)` method.
    ///
    ///  - parameter tableView: The table view in which to perform deselection/reselection.
    func rz_smoothlyDeselectRows(tableView: UITableView?) {
        let selectedIndexPaths = tableView?.indexPathsForSelectedRows ?? []
        
        if let coordinator = transitionCoordinator {
            coordinator.animateAlongsideTransition(in: parent?.view, animation: { context in
                selectedIndexPaths.forEach {
                    tableView?.deselectRow(at: $0, animated: context.isAnimated)
                }
                }, completion: { context in
                    if context.isCancelled {
                        selectedIndexPaths.forEach {
                            tableView?.selectRow(at: $0, animated: false, scrollPosition: .none)
                        }
                    }
            })
        }
        else {
            selectedIndexPaths.forEach {
                tableView?.deselectRow(at: $0, animated: false)
            }
        }
    }
}
