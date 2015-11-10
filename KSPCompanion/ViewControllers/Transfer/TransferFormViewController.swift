//
//  TransferViewController.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 04/06/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import UIKit
import Crashlytics
import Eureka
import TSMessages

class TransferFormViewController: FormViewController {
    
    var celestials = [Celestial]()
    
    var results: (parent: Celestial, from: Celestial, to: Celestial, phaseAngle: Double, ejectionAngle: Double, ejectionSpeed: Double, deltaV: Double)?
    
    func loadCelestials() {
        var newData = DataManager.getCelestialsFromJson()
        newData.removeAtIndex(0) // Getting rid of Kerbol
        if celestials.count != newData.count {
            celestials = newData
            self.setupForm()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.navigationController != nil {
            self.navigationController!.topViewController!.title = NSLocalizedString("TRANSFER", comment: "")
        }
        
        loadCelestials()
        
        if (UI_USER_INTERFACE_IDIOM() != .Pad) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("CALCULATE", comment: ""), style: .Plain, target: self, action: "submit:")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // refreshing data
        loadCelestials()
    }
    
    func submit(sender: AnyObject) {
        let results = form.values()
        
        if let indexPath = tableView!.indexPathForSelectedRow {
            tableView!.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        guard let from = results["from"] as? Celestial, dest = results["to"] as? Celestial else { print("not celestial"); return }
        if from != dest {
            guard let alt = results["altitude"] as? Int else { print("not int"); return }
            if alt > 0 {
                if let calcul = from.transfertTo(dest, withAltitude: Double(alt)) {
                    self.results = calcul
                    Answers.logCustomEventWithName("TransferCalculation", customAttributes: ["from": from.name, "to": dest.name, "parking": alt])
                    performSegueWithIdentifier("calculateSegue", sender: self)
                }
                else {
                    TSMessage.showNotificationWithTitle(NSLocalizedString("COULD_NOT_CALCUL_NOTIF", comment: ""), subtitle: NSLocalizedString("NOT_AROUND_SAME_CELESTIAL", comment: ""), type: .Error)
                }
            }
        } else {
            TSMessage.showNotificationWithTitle(NSLocalizedString("COULD_NOT_CALCUL_NOTIF", comment: ""), subtitle: NSLocalizedString("SAME_CELESTIAL", comment: ""), type: .Error)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.view.endEditing(true)
        
        if segue.identifier == "calculateSegue" {
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! TransferResultTableViewController
            if let results = self.results {
                controller.prepare(results)
            }
        }
    }
    
    func setupForm() {
        form.removeAll()
        
        form +++
            Section(header: HeaderFooterView<UIView>(stringLiteral: NSLocalizedString("INTERPLANETARY_TRANSFER_HEADER", comment: "")), footer: HeaderFooterView<UIView>(stringLiteral: NSLocalizedString("INTERPLANETARY_TRANSFER_FOOTER", comment: "")))
            <<< IntRow("altitude") {
                $0.title = NSLocalizedString("PARKING_ALTITURE", comment: "")
                $0.value = 100000
                $0.placeholder = NSLocalizedString("PARKING_ALTITUDE_PLACEHOLDER", comment: "")
                $0.placeholderColor = UIColor.grayColor()
            }
            <<< PushRow<Celestial>("from") {
                $0.title = NSLocalizedString("FROM", comment: "")
                $0.options = self.celestials
                $0.value = SettingsManager.solarSystem == .KerbolPlus ? self.celestials[4] : self.celestials[3] // Kerbin
            }
            <<< PushRow<Celestial>("to") {
                $0.title = NSLocalizedString("TO", comment: "")
                $0.options = self.celestials
                $0.value = SettingsManager.solarSystem == .KerbolPlus ? self.celestials[8] : self.celestials[6] // Duna
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

extension String {
    var toDouble: Double? {
        return NSNumberFormatter().numberFromString(self)?.doubleValue
    }
}