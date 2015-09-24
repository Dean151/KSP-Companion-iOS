//
//  TransfertResultTableViewController.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 23/09/2015.
//  Copyright © 2015 Thomas Durand. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import TSMessages

class TransferResultTableViewController: UITableViewController, DZNEmptyDataSetSource {
    
    var results: (parent: Celestial, from: Celestial, to: Celestial, phaseAngle: Double, ejectionAngle: Double, ejectionSpeed: Double, deltaV: Double)?
    var inclinationAlertHavePoped = false
    func prepare(results: (parent: Celestial, from: Celestial, to: Celestial, phaseAngle: Double, ejectionAngle: Double, ejectionSpeed: Double, deltaV: Double)) {
        self.results = results
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.emptyDataSetSource = self
        
        if let r = self.results {
            if self.navigationController != nil {
                self.navigationController!.topViewController!.title = "\(r.from.name) → \(r.to.name)"
            }
            
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let r = results {
            if r.from.orbit!.inclination != r.to.orbit!.inclination || r.from.orbit!.ascendingNodeLongitude != r.to.orbit!.ascendingNodeLongitude {
                if !inclinationAlertHavePoped {
                    TSMessage.showNotificationWithTitle(NSLocalizedString("INCLINATION_NOTIF", comment: ""), subtitle: NSLocalizedString("INCLINATION_NOTIF_DESC", comment: ""), type: .Warning)
                    inclinationAlertHavePoped = true
                }
            }
        }
    }
    
    // MARK: TableView
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if results == nil {
            return 0
        }
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("PHASE_ANGLE_HEADER", comment: "")
        case 1:
            return NSLocalizedString("MANOEUVER_HEADER", comment: "")
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("PHASE_ANGLE_FOOTER", comment: "")
        case 1:
            return NSLocalizedString("MANOEUVER_FOOTER", comment: "")
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TransfertResultCell", forIndexPath: indexPath)
        
        switch indexPath.section {
        case 0:
            cell.accessoryType = .DetailButton
            cell.textLabel!.text = NSLocalizedString("PHASE_ANGLE", comment: "")
            cell.detailTextLabel!.text = "\(self.results!.phaseAngle.format(2))°"
        case 1:
            switch indexPath.row {
            case 0:
                cell.accessoryType = .DetailButton
                cell.textLabel!.text = NSLocalizedString("ANGLE", comment: "")
                cell.detailTextLabel!.text = "\(self.results!.ejectionAngle.format(2))°"
            case 1:
                cell.textLabel!.text = NSLocalizedString("TARGETED_SPEED", comment: "")
                cell.detailTextLabel!.text = "\(self.results!.ejectionSpeed.format(1)) m/s"
                break
            case 2:
                cell.textLabel!.text = NSLocalizedString("PROGRADE_DV", comment: "")
                cell.detailTextLabel!.text = "\(self.results!.deltaV.format(1)) m/s"
                break
            default:
                break
            }
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        var modalViewController: TransferResultModalController?
        
        switch indexPath.section {
        case 0:
            modalViewController = TransferPhaseAngleViewController()
        case 1:
            modalViewController = TransferManoeuverViewController()
        default:
            break
        }
        
        if let mvc = modalViewController, results = self.results {
            mvc.results = results
            
            let navController = UINavigationController(rootViewController: mvc)
            navController.modalPresentationStyle = .FormSheet
            
            self.presentViewController(navController, animated: true, completion: nil)
        }
    }
    
    // MARK: DZNEmptyDataSetSource
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = NSLocalizedString("DO_A_CALCUL", comment: "")
        
        let attributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(18), NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = NSLocalizedString("DO_A_CALCUL_DESC", comment: "")
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .ByWordWrapping
        paragraph.alignment = .Center
        
        let attributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(14),
            NSForegroundColorAttributeName: UIColor.lightGrayColor(),
            NSParagraphStyleAttributeName: paragraph]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
}
