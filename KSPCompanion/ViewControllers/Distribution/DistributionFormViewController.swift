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

enum DistributionError {
    case notHighEnough, notLowEnough, notEnoughSats
    
    func showMessage(_ showMessage: Bool) {
        if !showMessage {
            return
        }
        
        switch self {
        case .notHighEnough:
            TSMessage.showNotification(withTitle: NSLocalizedString("TOO_LOW_NOTIF", comment: ""), subtitle: NSLocalizedString("TOO_LOW_NOTIF_DESC", comment: ""), type: .error)
        case .notLowEnough:
            TSMessage.showNotification(withTitle: NSLocalizedString("TOO_HIGH_NOTIF", comment: ""), subtitle: NSLocalizedString("TOO_HIGH_NOTIF_DESC", comment: ""), type: .error)
        case .notEnoughSats:
            TSMessage.showNotification(withTitle: NSLocalizedString("NOT_ENOUGH_NOTIF", comment: ""), subtitle: NSLocalizedString("NOT_ENOUGH_NOTIF_DESC", comment: ""), type: .error)
        }
    }
}

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
        
        if (UI_USER_INTERFACE_IDIOM() == .phone) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("CALCULATE", comment: ""), style: .plain, target: self, action: #selector(DistributionFormViewController.submit(_:)))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // refreshing data
        loadCelestials()
    }
    
    func doTheMaths(_ showMessage: Bool) -> (targetOrbit: Orbit, transferOrbit: Orbit, nSat: Int, deltaV: Double)? {
        let results = self.form.values()
        
        guard Settings.sharedInstance.canDoCalculation else {
            let alert = UIAlertController(title: NSLocalizedString("ONLY_X_CALCULATION", comment: ""), message: NSLocalizedString("COMPLETE_VERSION_FOOTER", comment: ""), preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("BUY_IN_SETTINGS", comment: ""), style: .default, handler: { action in
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                _ = appDelegate?.handleQuickAction(.Settings)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            return nil
        }
        
        guard let nbsat = results["number"] as? Int, let cel = results["celestial"] as? Celestial, let typeOrbit = results["orbittype"] as? String else { return nil }
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
                    DistributionError.notHighEnough.showMessage(showMessage)
                    return nil
                }
            }
            
            // Check for sphere of influence
            if targetAltitude > cel.sphereOfInfluence {
                DistributionError.notLowEnough.showMessage(showMessage)
                return nil
            }
            
            // Check for satellite numbers
            if nbsat < 2 {
                DistributionError.notEnoughSats.showMessage(showMessage)
                return nil
            }
            
            if let transferAltitude = cel.distributeSatellitesAtAltitude(targetAltitude, numberOfSatellites: nbsat) {
                let apoapsis = transferAltitude > targetAltitude ? transferAltitude : targetAltitude
                let periapsis = transferAltitude < targetAltitude ? transferAltitude : targetAltitude
                let transferOrbit = Orbit(orbitAround: cel, apoapsis: apoapsis+cel.radius, periapsis: periapsis+cel.radius)
                let targetOrbit = Orbit(orbitAround: cel, apoapsis: targetAltitude+cel.radius, periapsis: targetAltitude+cel.radius)
                let deltaV = abs(targetOrbit.apoapsisVelocity - transferOrbit.apoapsisVelocity )
                
                Answers.logCustomEvent(withName: "DistributionCalculation", customAttributes: ["around": cel.name, "satNb": nbsat, "alt": targetAltitude])
                Settings.sharedInstance.numberOfCalculations += 1
                return (targetOrbit, transferOrbit, nbsat, deltaV)
            }
        } else {
            DistributionError.notHighEnough.showMessage(false)
        }
        
        return nil
    }
    
    func submit(_ sender: AnyObject!) {
        if let indexPath = tableView!.indexPathForSelectedRow {
            tableView!.deselectRow(at: indexPath, animated: true)
        }
        
        guard let calcul = self.doTheMaths(true) else { return }
        self.results = calcul
        
        performSegue(withIdentifier: "calculateSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.view.endEditing(true)
        
        if segue.identifier == "calculateSegue" {
            let controller = (segue.destination as! UINavigationController).topViewController as! DistributionResultTableViewController
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
                $0.value = Settings.sharedInstance.solarSystem == .kerbolPlus ? self.celestials[5] : self.celestials[4] // Kerbin
            }.onChange(self.formChanged)
            
            <<< IntRow("number") {
                $0.title = NSLocalizedString("NUMBER_OF_SATELLITES", comment: "")
                $0.value = 3
                $0.placeholder = NSLocalizedString("NUMBER_OF_SATELLITES_PLACEHOLDER", comment: "")
                $0.placeholderColor = UIColor.gray
            }
            
            <<< SegmentedRow<String>("orbittype") {
                $0.title = NSLocalizedString("ORBIT", comment: "")
                $0.options = self.orbitOptions
                $0.value = self.orbitOptions[0]
            }.onChange(self.formChanged)
            
            <<< IntRow("altitude") {
                $0.title = NSLocalizedString("TARGETED_ALTITUDE", comment: "")
                $0.hidden = .function(["orbittype"], { form in
                    if let r1 : SegmentedRow<String> = form.rowBy(tag: "orbittype") {
                        return r1.value != self.orbitOptions[2]
                    }
                    return true
                })
                $0.placeholder = NSLocalizedString("TARGETED_ALTITUDE_PLACEHOLDER", comment: "")
                $0.placeholderColor = UIColor.gray
            }
        
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            form +++ ButtonRow("calculate") {
                $0.title = NSLocalizedString("CALCULATE", comment: "")
                $0.cell.tintColor = UIColor.appGreenColor
            }.onCellSelection { (cell, row) in
                self.submit(row)
            }
        }
    }
    
    func formChanged(_ row: BaseRow) {
        if !self.splitViewController!.isCollapsed {
            self.tableView?.reloadData()
            self.submit(self)
        }
    }
}
