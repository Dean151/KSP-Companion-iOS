//
//  SolarSystemSelector.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 23/09/2015.
//  Copyright © 2015 Thomas Durand. All rights reserved.
//

import UIKit

class SolarSystemSelector: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var tableView: UITableView!
    var parentController: CelestialsTableViewController?
    
    override func loadView() {
        super.loadView()
        
        self.view = UITableView(frame: CGRect.zero, style: .grouped)
        self.tableView = self.view as! UITableView
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add title to navbar
        self.navigationItem.title = NSLocalizedString("SYSTEMS", comment: "")
        
        // Constraint for popover view
        self.preferredContentSize = CGSize(width: 320, height: 130 + 44*CGFloat(SolarSystem.count))
        
        // Adding button to dismiss view
        let dismissButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(SolarSystemSelector.dismiss(_:)))
        self.navigationItem.rightBarButtonItem = dismissButton;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let parent = self.parentController {
            parent.loadCelestials()
        }
    }
    
    func dismiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Mark: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SolarSystem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        if let solarSystem = SolarSystem(rawValue: indexPath.row) {
            cell.textLabel?.text = "\(solarSystem)"
            if solarSystem == Settings.sharedInstance.solarSystem {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard Settings.sharedInstance.completeVersionPurchased || indexPath.row == 0 else {
            // We can't change
            let alert = UIAlertController(title: NSLocalizedString("COMPLETE_VERSION_FEATURE", comment: ""), message: NSLocalizedString("COMPLETE_VERSION_FOOTER", comment: ""), preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("BUY_IN_SETTINGS", comment: ""), style: .default, handler: { action in
                self.dismiss(animated: true, completion: {
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    _ = appDelegate?.handleQuickAction(.Settings)
                })
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if let solarSystem = SolarSystem(rawValue: indexPath.row) {
            Settings.sharedInstance.solarSystem = solarSystem
            self.dismiss(self)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return NSLocalizedString("SYSTEM_SELECTION_DESCRIPTION", comment: "")
    }
}
