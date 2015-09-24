//
//  TransferResultViewController.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 09/06/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import UIKit
import TSMessages

class TransferResultViewController: UITableViewController {
    
    @IBOutlet weak var phaseAngleLabel: UILabel!
    @IBOutlet weak var ejectionAngleLabel: UILabel!
    @IBOutlet weak var ejectionVelocityLabel: UILabel!
    @IBOutlet weak var deltaVLabel: UILabel!
    
    var results: (parent: Celestial, from: Celestial, to: Celestial, phaseAngle: Double, ejectionAngle: Double, ejectionSpeed: Double, deltaV: Double)?
    
    var inclinationAlertHavePoped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let r = results {
            if self.navigationController != nil {
                self.navigationController!.topViewController!.title = "\(r.from.name) → \(r.to.name)"
            }
            
            phaseAngleLabel.text = "\(r.phaseAngle.format(2))°"
            ejectionAngleLabel.text = "\(r.ejectionAngle.format(2))°"
            ejectionVelocityLabel.text = "\(r.ejectionSpeed.format(1)) m/s"
            deltaVLabel.text = "\(r.deltaV.format(1)) m/s"
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
    
    func prepare(results: (parent: Celestial, from: Celestial, to: Celestial, phaseAngle: Double, ejectionAngle: Double, ejectionSpeed: Double, deltaV: Double)) {
        self.results = results
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if results != nil {
            if let nav = segue.destinationViewController as? UINavigationController {
                if segue.identifier == "phaseAngleModal" {
                    if let destination = nav.childViewControllers[0] as? TransferPhaseAngleViewController {
                        destination.prepare(results!)
                    } else {
                        print("not TransferPhaseAngleViewController")
                    }
                }
                
                if segue.identifier == "manoeuverModal" {
                    if let destination = nav.childViewControllers[0] as? TransferManoeuverViewController {
                        destination.prepare(results!)
                    } else {
                        print("not TransferManoeuverViewController")
                    }
                }
            }
        }
    }
}