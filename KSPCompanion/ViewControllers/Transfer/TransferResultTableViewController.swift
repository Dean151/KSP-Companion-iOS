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
    func prepare(_ results: (parent: Celestial, from: Celestial, to: Celestial, phaseAngle: Double, ejectionAngle: Double, ejectionSpeed: Double, deltaV: Double)) {
        self.results = results
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.emptyDataSetSource = self
        self.tableView.allowsSelection = false
        
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let r = results {
            if self.navigationController != nil {
                self.navigationController!.topViewController!.title = "\(r.from.name) → \(r.to.name)"
            }
            
            if r.from.orbit!.inclination != r.to.orbit!.inclination || r.from.orbit!.ascendingNodeLongitude != r.to.orbit!.ascendingNodeLongitude {
                if !inclinationAlertHavePoped {
                    TSMessage.showNotification(withTitle: NSLocalizedString("INCLINATION_NOTIF", comment: ""), subtitle: NSLocalizedString("INCLINATION_NOTIF_DESC", comment: ""), type: .warning)
                    inclinationAlertHavePoped = true
                }
            }
        }
    }
    
    // MARK: TableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if results == nil {
            return 0
        }
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("PHASE_ANGLE_HEADER", comment: "")
        case 1:
            return NSLocalizedString("MANOEUVER_HEADER", comment: "")
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("PHASE_ANGLE_FOOTER", comment: "")
        case 1:
            return NSLocalizedString("MANOEUVER_FOOTER", comment: "")
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransfertResultCell", for: indexPath)
        
        switch indexPath.section {
        case 0:
            cell.accessoryType = .detailButton
            cell.textLabel!.text = NSLocalizedString("PHASE_ANGLE", comment: "")
            cell.detailTextLabel!.text = "\(self.results!.phaseAngle.format(2))°"
        case 1:
            switch indexPath.row {
            case 0:
                cell.accessoryType = .detailButton
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
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        var modalViewController: TransferResultModalController?
        
        switch indexPath.section {
        case 0:
            modalViewController = TransferPhaseAngleViewController()
        case 1:
            modalViewController = TransferManoeuverViewController()
        default:
            break
        }
        
        if let mvc = modalViewController, let results = self.results {
            mvc.results = results
            
            let navController = UINavigationController(rootViewController: mvc)
            navController.modalPresentationStyle = .formSheet
            
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    // MARK: DZNEmptyDataSetSource
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = NSLocalizedString("DO_A_CALCUL", comment: "")
        
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18), NSForegroundColorAttributeName: UIColor.darkGray]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = NSLocalizedString("DO_A_CALCUL_DESC", comment: "")
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14),
            NSForegroundColorAttributeName: UIColor.lightGray,
            NSParagraphStyleAttributeName: paragraph]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
}
