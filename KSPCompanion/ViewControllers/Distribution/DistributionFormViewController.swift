//
//  DistributionFormViewController.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 11/06/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import UIKit
import Crashlytics
import Eureka
import TSMessages

class DistributionFormViewController: FormViewController {
    var celestials = [Celestial]()
    let orbitOptions = ["Sync.", "Semisync.", NSLocalizedString("CUSTOM", comment: "")]
    var results: (targetOrbit: Orbit, transferOrbit: Orbit, nSat: Int, deltaV: Double)?
    
    
    func loadCelestials() {
        let newData = DataManager.getCelestialsFromJson()
        if celestials.count != newData.count {
            celestials = newData
            self.setupForm()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.navigationController != nil {
            self.navigationController!.topViewController!.title = NSLocalizedString("DISTRIBUTION", comment: "")
        }
        
        loadCelestials()
        
        if (UI_USER_INTERFACE_IDIOM() == .Phone) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("CALCULATE", comment: ""), style: .Plain, target: self, action: "submit:")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // refreshing data
        loadCelestials()
    }
    
    func submit(sender: AnyObject!) {
        let results = self.form.values()
        
        if let indexPath = tableView!.indexPathForSelectedRow {
            tableView!.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        guard let nbsat = results["number"] as? Int, cel = results["celestial"] as? Celestial, typeOrbit = results["orbittype"] as? String else { return }
        var targetAltitude: Double = 0
        
        if typeOrbit == orbitOptions[0] {
            targetAltitude = cel.synchronousOrbitAltitude
        } else if typeOrbit == orbitOptions[1] {
            targetAltitude = cel.semiSynchronousOrbitAltitude
        } else {
            if let alt = results["altitude"] as? Int {
                targetAltitude = Double(alt)
            }
        }
        
        if targetAltitude > 0 {
            // Check for atmosphere
            if let atmo = cel.atmosphere {
                if targetAltitude < atmo.limitAltitude {
                    TSMessage.showNotificationWithTitle(NSLocalizedString("TOO_LOW_NOTIF", comment: ""), subtitle: NSLocalizedString("TOO_LOW_NOTIF_DESC", comment: ""), type: .Error)
                    return
                }
            }
            
            // Check for sphere of influence
            if targetAltitude > cel.sphereOfInfluence {
                TSMessage.showNotificationWithTitle(NSLocalizedString("TOO_HIGH_NOTIF", comment: ""), subtitle: NSLocalizedString("TOO_HIGH_NOTIF_DESC", comment: ""), type: .Error)
                return
            }
            
            // Check for satellite numbers
            if nbsat < 2 {
                TSMessage.showNotificationWithTitle(NSLocalizedString("NOT_ENOUGH_NOTIF", comment: ""), subtitle: NSLocalizedString("NOT_ENOUGH_NOTIF_DESC", comment: ""), type: .Error)
                return
            }
            
            if let transferAltitude = cel.distributeSatellitesAtAltitude(targetAltitude, numberOfSatellites: nbsat) {
                let apoapsis = transferAltitude > targetAltitude ? transferAltitude : targetAltitude
                let periapsis = transferAltitude < targetAltitude ? transferAltitude : targetAltitude
                let transferOrbit = Orbit(orbitAround: cel, apoapsis: apoapsis+cel.radius, periapsis: periapsis+cel.radius)
                let targetOrbit = Orbit(orbitAround: cel, apoapsis: targetAltitude+cel.radius, periapsis: targetAltitude+cel.radius)
                let deltaV = abs(targetOrbit.apoapsisVelocity - transferOrbit.apoapsisVelocity )
                
                self.results = (targetOrbit, transferOrbit, nbsat, deltaV)
                
                Answers.logCustomEventWithName("DistributionCalculation", customAttributes: ["around": cel.name, "satNb": nbsat, "alt": targetAltitude])
                
                performSegueWithIdentifier("calculateSegue", sender: self)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.view.endEditing(true)
        
        if segue.identifier == "calculateSegue" {
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DistributionResultTableViewController
            if let r = self.results {
                controller.prepare(r)
            }
        }
    }
    
    func setupForm() {
        form.removeAll()
        
        form +++
            Section(header: NSLocalizedString("DISTRIBUTE_SATELLITE_HEADER", comment: ""), footer: NSLocalizedString("DISTRIBUTE_SATELLITE_FOOTER", comment: ""))
            
            <<< PushRow<Celestial>("celestial") {
                $0.title = NSLocalizedString("ORBIT_AROUND", comment: "")
                $0.options = self.celestials
                $0.value = Settings.sharedInstance.solarSystem == .KerbolPlus ? self.celestials[5] : self.celestials[4] // Kerbin
            }
            
            <<< IntRow("number") {
                $0.title = NSLocalizedString("NUMBER_OF_SATELLITES", comment: "")
                $0.value = 3
                $0.placeholder = NSLocalizedString("NUMBER_OF_SATELLITES_PLACEHOLDER", comment: "")
                $0.placeholderColor = UIColor.grayColor()
            }
            
            <<< SegmentedRow<String>("orbittype") {
                $0.title = NSLocalizedString("ORBIT", comment: "")
                $0.options = self.orbitOptions
                $0.value = self.orbitOptions[0]
            }
            
            <<< IntRow("altitude") {
                $0.title = NSLocalizedString("TARGETED_ALTITUDE", comment: "")
                $0.hidden = .Function(["orbittype"], { form in
                    if let r1 : SegmentedRow<String> = form.rowByTag("orbittype") {
                        return r1.value != self.orbitOptions[2]
                    }
                    return true
                })
                $0.placeholder = NSLocalizedString("TARGETED_ALTITUDE_PLACEHOLDER", comment: "")
                $0.placeholderColor = UIColor.grayColor()
            }
        
        if (UI_USER_INTERFACE_IDIOM() == .Pad) {
            form +++= ButtonRow("calculate") {
                $0.title = NSLocalizedString("CALCULATE", comment: "")
                $0.cell.tintColor = UIColor.appGreenColor
            }.onCellSelection { (cell, row) in
                self.submit(row)
            }
        }
    }
}
