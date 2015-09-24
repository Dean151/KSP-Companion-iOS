//
//  DistributionFormViewController.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 11/06/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import UIKit
import XLForm
import TSMessages

class DistributionFormViewController: XLFormViewController {
    var celestials = [Celestial]()
    let orbitOptions = ["Sync.", "Semisync.", NSLocalizedString("CUSTOM", comment: "")]
    var results: (targetOrbit: Orbit, transferOrbit: Orbit, nSat: Int)?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        celestials = DataManager.getCelestialsFromJson()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.navigationController != nil {
            self.navigationController!.topViewController!.title = NSLocalizedString("DISTRIBUTION", comment: "")
        }
        
        self.setupForm()
        
        if (UI_USER_INTERFACE_IDIOM() == .Phone) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("CALCULATE", comment: ""), style: .Plain, target: self, action: "submit:")
        }
    }
    
    func submit(sender: UIBarButtonItem!) {
        let results = self.form.formValues()
        if let nbsat = results["number"] as? Int {
            if let cel = results["celestial"] as? Celestial {
                if let typeOrbit = results["orbitType"] as? String {
                    var targetAltitude: Double = 0
                    
                    if typeOrbit == orbitOptions[0] {
                        targetAltitude = cel.synchronousOrbitAltitude
                    } else if typeOrbit == orbitOptions[1] {
                        targetAltitude = cel.semiSynchronousOrbitAltitude
                    } else {
                        if let alt = results["altitude"] as? Double {
                            targetAltitude = alt
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
                            let transitOrbit = Orbit(orbitAround: cel, apoapsis: apoapsis+cel.radius, periapsis: periapsis+cel.radius)
                            let targetOrbit = Orbit(orbitAround: cel, apoapsis: targetAltitude+cel.radius, periapsis: targetAltitude+cel.radius)
                            
                            self.results = (targetOrbit, transitOrbit, nbsat)
                            
                            performSegueWithIdentifier("calculateSegue", sender: self)
                        }
                    }
                } else {
                    print("No typeOrbit")
                }
            } else {
                print("No celestial")
            }
        } else {
            print("No satellite number")
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
        let form = XLFormDescriptor()
        
        var section = XLFormSectionDescriptor.formSectionWithTitle(NSLocalizedString("DISTRIBUTE_SATELLITE_HEADER", comment: ""))
        section.footerTitle = NSLocalizedString("DISTRIBUTE_SATELLITE_FOOTER", comment: "")
        
        var row: XLFormRowDescriptor!
        
        // Celestial selector
        row = XLFormRowDescriptor(tag: "celestial", rowType: XLFormRowDescriptorTypeSelectorPush, title: NSLocalizedString("ORBIT_AROUND", comment: ""))
        row.required = true
        row.selectorOptions = self.celestials
        row.value = celestials[4] // Kerbin
        section.addFormRow(row)
        
        // Number of satellites
        row = XLFormRowDescriptor(tag: "number", rowType: XLFormRowDescriptorTypeInteger, title: NSLocalizedString("NUMBER_OF_SATELLITES", comment: ""))
        row.required = true
        row.cellConfigAtConfigure["textField.placeholder"] = NSLocalizedString("NUMBER_OF_SATELLITES_PLACEHOLDER", comment: "")
        row.cellConfig["textField.textAlignment"] = NSTextAlignment.Right.rawValue
        row.cellConfig["textField.textColor"] = UIColor.grayColor()
        row.value = 3
        section.addFormRow(row)
        
        // Type of orbit
        let orbitType = XLFormRowDescriptor(tag: "orbitType", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: NSLocalizedString("ORBIT", comment: ""))
        row.required = true
        orbitType.selectorOptions = orbitOptions
        orbitType.value = orbitOptions[0]
        section.addFormRow(orbitType)
        
        // Targeted altitude
        row = XLFormRowDescriptor(tag: "altitude", rowType: XLFormRowDescriptorTypeInteger, title: NSLocalizedString("TARGETED_ALTITUDE", comment: ""))
        row.cellConfigAtConfigure["textField.placeholder"] = NSLocalizedString("TARGETED_ALTITUDE_PLACEHOLDER", comment: "")
        row.cellConfig["textField.textAlignment"] = NSTextAlignment.Right.rawValue
        row.cellConfig["textField.textColor"] = UIColor.grayColor()
        row.hidden = String.localizedStringWithFormat("$orbitType.value!='%@'", orbitOptions[2])
        section.addFormRow(row)
        
        form.addFormSection(section)
        
        if (UI_USER_INTERFACE_IDIOM() == .Pad) {
            section = XLFormSectionDescriptor.formSection()
            row = XLFormRowDescriptor(tag: "calculate", rowType: XLFormRowDescriptorTypeButton, title: NSLocalizedString("CALCULATE", comment: ""))
            row.action.formSelector = "submit:"
            section.addFormRow(row)
            
            form.addFormSection(section)
        }
        
        self.form = form
    }
}
