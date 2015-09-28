//
//  TransferViewController.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 04/06/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import UIKit
import XLForm
import TSMessages

class TransferFormViewController: XLFormViewController {
    
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
        
        if (UI_USER_INTERFACE_IDIOM() == .Phone) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("CALCULATE", comment: ""), style: .Plain, target: self, action: "submit:")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // refreshing data
        loadCelestials()
    }
    
    func submit(sender: AnyObject) {
        let results = self.form.formValues()
        
        if let indexPath = tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        guard let from = results["from"] as? Celestial, dest = results["to"] as? Celestial else { return }
        if from != dest {
            guard let alt = results["altitude"] as? Double else { return }
            if alt > 0 {
                if let calcul = from.transfertTo(dest, withAltitude: alt) {
                    self.results = calcul
                    
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
        let form = XLFormDescriptor()
        
        var section = XLFormSectionDescriptor.formSectionWithTitle(NSLocalizedString("INTERPLANETARY_TRANSFER_HEADER", comment: ""))
        section.footerTitle = NSLocalizedString("INTERPLANETARY_TRANSFER_FOOTER", comment: "")
        
        var row: XLFormRowDescriptor!
        
        // altitude selector
        row = XLFormRowDescriptor(tag: "altitude", rowType: XLFormRowDescriptorTypeInteger, title: NSLocalizedString("PARKING_ALTITURE", comment: ""))
        row.required = true
        row.value = 100000
        row.cellConfigAtConfigure["textField.placeholder"] = NSLocalizedString("PARKING_ALTITUDE_PLACEHOLDER", comment: "")
        row.cellConfig["textField.textAlignment"] = NSTextAlignment.Right.rawValue
        row.cellConfig["textField.textColor"] = UIColor.grayColor()
        section.addFormRow(row)
        
        // From selector
        row = XLFormRowDescriptor(tag: "from", rowType: XLFormRowDescriptorTypeSelectorPush, title: NSLocalizedString("FROM", comment: ""))
        row.required = true
        row.selectorOptions = self.celestials
        row.value = celestials[3] // Kerbin
        section.addFormRow(row)
        
        // To selector
        row = XLFormRowDescriptor(tag: "to", rowType: XLFormRowDescriptorTypeSelectorPush, title: NSLocalizedString("TO", comment: ""))
        row.required = true
        row.selectorOptions = self.celestials
        row.value = celestials[6] // Duna
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

extension String {
    var toDouble: Double? {
        return NSNumberFormatter().numberFromString(self)?.doubleValue
    }
}