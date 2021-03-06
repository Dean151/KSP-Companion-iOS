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
    case sameCelestial, notAroundSameCelestial, notRoundEnough, notHighEnough
    
    func showMessage(_ showMessage: Bool) {
        if !showMessage {
            return
        }
        
        switch self {
        case .sameCelestial:
            TSMessage.showNotification(withTitle: NSLocalizedString("COULD_NOT_CALCUL_NOTIF", comment: ""), subtitle: NSLocalizedString("SAME_CELESTIAL", comment: ""), type: .error)
        case .notAroundSameCelestial:
            TSMessage.showNotification(withTitle: NSLocalizedString("COULD_NOT_CALCUL_NOTIF", comment: ""), subtitle: NSLocalizedString("NOT_AROUND_SAME_CELESTIAL", comment: ""), type: .error)
        case .notRoundEnough:
            TSMessage.showNotification(withTitle: NSLocalizedString("FROM_DEST_NOT_ROUND_ENOUGH", comment: ""), subtitle: NSLocalizedString("FROM_DEST_NOT_ROUND_ENOUGH_DESC", comment: ""), type: .error)
        case .notHighEnough:
            break
        }
    }
}

class TransferFormViewController: FormViewController {
    var celestials = [Celestial]()
    
    var results: (parent: Celestial, from: Celestial, to: Celestial, phaseAngle: Double, ejectionAngle: Double, ejectionSpeed: Double, deltaV: Double)?
    
    func loadCelestials() {
        var newData = DataManager.getCelestialsFromJson()
        newData.remove(at: 0) // Getting rid of Kerbol
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
        
        if (UI_USER_INTERFACE_IDIOM() != .pad) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("CALCULATE", comment: ""), style: .plain, target: self, action: #selector(TransferFormViewController.submit(_:)))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // refreshing data
        loadCelestials()
    }
    
    func doTheMath(_ showMessage: Bool) -> (parent: Celestial, from: Celestial, to: Celestial, phaseAngle: Double, ejectionAngle: Double, ejectionSpeed: Double, deltaV: Double)? {
        let results = form.values()
        
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
        
        guard let from = results["from"] as? Celestial, let dest = results["to"] as? Celestial else { return nil }
        guard let alt = results["altitude"] as? Int else { return nil }
        if from != dest {
            if alt > 0 {
                if from.orbit!.eccentricity < 0.3 && dest.orbit!.eccentricity < 0.3 {
                    if let calcul = from.transfertTo(dest, withAltitude: Double(alt)) {
                        Answers.logCustomEvent(withName: "TransferCalculation", customAttributes: ["from": from.name, "to": dest.name, "altitude": alt])
                        Settings.sharedInstance.numberOfCalculations += 1
                        return calcul
                    }
                    else {
                        TransferError.notAroundSameCelestial.showMessage(showMessage)
                        return nil
                    }
                } else {
                    TransferError.notRoundEnough.showMessage(showMessage)
                    return nil
                }
            } else {
                TransferError.notHighEnough.showMessage(showMessage)
                return nil
            }
        } else {
            TransferError.sameCelestial.showMessage(showMessage)
            return nil
        }
    }
    
    func submit(_ sender: AnyObject) {
        if let indexPath = tableView!.indexPathForSelectedRow {
            tableView!.deselectRow(at: indexPath, animated: true)
        }
        
        guard let calcul = self.doTheMath(true) else { return }
        self.results = calcul
        
        performSegue(withIdentifier: "calculateSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.view.endEditing(true)
        
        if segue.identifier == "calculateSegue" {
            let controller = (segue.destination as! UINavigationController).topViewController as! TransferResultTableViewController
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
                $0.placeholderColor = UIColor.gray
            }
            <<< PushRow<Celestial>("from") {
                $0.title = NSLocalizedString("FROM", comment: "")
                $0.options = self.celestials
                $0.value = Settings.sharedInstance.solarSystem == .kerbolPlus ? self.celestials[4] : self.celestials[3] // Kerbin
            }.onChange(self.formChanged)
            <<< PushRow<Celestial>("to") {
                $0.title = NSLocalizedString("TO", comment: "")
                $0.options = self.celestials
            }.onChange(self.formChanged)
        
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

extension String {
    var toDouble: Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}
