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

enum TransferError {
    case SameCelestial, NotAroundSameCelestial, NotRoundEnough, NotHighEnough
    
    func showMessage(showMessage: Bool) {
        if !showMessage {
            return
        }
        
        switch self {
        case .SameCelestial:
            TSMessage.showNotificationWithTitle(NSLocalizedString("COULD_NOT_CALCUL_NOTIF", comment: ""), subtitle: NSLocalizedString("SAME_CELESTIAL", comment: ""), type: .Error)
        case .NotAroundSameCelestial:
            TSMessage.showNotificationWithTitle(NSLocalizedString("COULD_NOT_CALCUL_NOTIF", comment: ""), subtitle: NSLocalizedString("NOT_AROUND_SAME_CELESTIAL", comment: ""), type: .Error)
        case .NotRoundEnough:
            TSMessage.showNotificationWithTitle(NSLocalizedString("FROM_DEST_NOT_ROUND_ENOUGH", comment: ""), subtitle: NSLocalizedString("FROM_DEST_NOT_ROUND_ENOUGH_DESC", comment: ""), type: .Error)
        case .NotHighEnough:
            break
        }
    }
}

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
    
    func doTheMath(showMessage: Bool) -> (parent: Celestial, from: Celestial, to: Celestial, phaseAngle: Double, ejectionAngle: Double, ejectionSpeed: Double, deltaV: Double)? {
        let results = form.values()
        
        guard let from = results["from"] as? Celestial, dest = results["to"] as? Celestial else { return nil }
        guard let alt = results["altitude"] as? Int else { return nil }
        if from != dest {
            if alt > 0 {
                if from.orbit!.eccentricity < 0.3 && dest.orbit!.eccentricity < 0.3 {
                    if let calcul = from.transfertTo(dest, withAltitude: Double(alt)) {
                        Answers.logCustomEventWithName("TransferCalculation", customAttributes: ["from": from.name, "to": dest.name, "altitude": alt])
                        return calcul
                    }
                    else {
                        TransferError.NotAroundSameCelestial.showMessage(showMessage)
                        return nil
                    }
                } else {
                    TransferError.NotRoundEnough.showMessage(showMessage)
                    return nil
                }
            } else {
                TransferError.NotHighEnough.showMessage(showMessage)
                return nil
            }
        } else {
            TransferError.SameCelestial.showMessage(showMessage)
            return nil
        }
    }
    
    func submit(sender: AnyObject) {
        if let indexPath = tableView!.indexPathForSelectedRow {
            tableView!.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        guard let calcul = self.doTheMath(true) else { return }
        self.results = calcul
        
        performSegueWithIdentifier("calculateSegue", sender: self)
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
            Section(header: NSLocalizedString("INTERPLANETARY_TRANSFER_HEADER", comment: ""), footer: NSLocalizedString("INTERPLANETARY_TRANSFER_FOOTER", comment: ""))
            <<< IntRow("altitude") {
                $0.title = NSLocalizedString("PARKING_ALTITURE", comment: "")
                $0.value = 100000
                $0.placeholder = NSLocalizedString("PARKING_ALTITUDE_PLACEHOLDER", comment: "")
                $0.placeholderColor = UIColor.grayColor()
            }
            <<< PushRow<Celestial>("from") {
                $0.title = NSLocalizedString("FROM", comment: "")
                $0.options = self.celestials
                $0.value = Settings.sharedInstance.solarSystem == .KerbolPlus ? self.celestials[4] : self.celestials[3] // Kerbin
            }.onChange(self.formChanged)
            <<< PushRow<Celestial>("to") {
                $0.title = NSLocalizedString("TO", comment: "")
                $0.options = self.celestials
            }.onChange(self.formChanged)
        
        if (UI_USER_INTERFACE_IDIOM() == .Pad) {
            form +++= ButtonRow("calculate") {
                $0.title = NSLocalizedString("CALCULATE", comment: "")
                $0.cell.tintColor = UIColor.appGreenColor
                }.onCellSelection { (cell, row) in
                    self.submit(row)
            }
        }
    }
    
    func formChanged(row: BaseRow) {
        if !self.splitViewController!.collapsed {
            self.tableView?.reloadData()
            self.submit(self)
        }
    }
}

extension String {
    var toDouble: Double? {
        return NSNumberFormatter().numberFromString(self)?.doubleValue
    }
}