//
//  SettingsViewController.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 24/09/2015.
//  Copyright © 2015 Thomas Durand. All rights reserved.
//

import UIKit
import Eureka
import IAPController

class SettingsViewController: FormViewController {
    let tempOptions = ["°C", "°F", "K"]
    
    var iapcontroller = IAPController.sharedInstance
    var iapFetched = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.navigationController != nil {
            self.navigationController!.topViewController!.title = NSLocalizedString("SETTINGS", comment: "")
        }
        
        setupForm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !Settings.sharedInstance.completeVersionPurchased && !iapFetched {
            setupIAP()
        }
    }
    
    func deselectButtons() {
        if let index = tableView!.indexPathForSelectedRow {
            tableView!.deselectRow(at: index, animated: true)
        }
    }
    
    func setupIAP() {
        iapcontroller.fetchProducts()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.didFetchedProducts(_:)), name: NSNotification.Name(rawValue: IAPControllerFetchedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.didPurchasedProduct(_:)), name: NSNotification.Name(rawValue: IAPControllerPurchasedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.didFailedToPurchaseProduct(_:)), name: NSNotification.Name(rawValue: IAPControllerFailedNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupForm() {
        form.removeAll()
        
        form +++
            Section(header: NSLocalizedString("SETTINGS", comment: ""), footer: NSLocalizedString("SETTINGS_FOOTER", comment: ""))
            
            <<< SegmentedRow<String>("temperature") {
                $0.title = NSLocalizedString("TEMPERATURE_UNIT", comment: "")
                $0.options = self.tempOptions
                $0.value = self.tempOptions[Settings.sharedInstance.temperatureUnit.rawValue]
            }.onChange { row in
                guard let tempString = row.value else { return }
                guard let temp = TemperatureUnit(rawValue: self.tempOptions.index(of: tempString)!) else { return }
                Settings.sharedInstance.temperatureUnit = temp
            }
            
            <<< SwitchRow("time") {
                $0.title = NSLocalizedString("KERBIN_TIME_UNITS", comment: "")
                $0.value = Settings.sharedInstance.useKerbinTime
            }.onChange { row in
                    guard let kerbinTime = row.value else { return }
                    Settings.sharedInstance.useKerbinTime = kerbinTime
            }
            
        
            +++ Section(header: NSLocalizedString("COMPLETE_VERSION", comment: ""), footer: NSLocalizedString("COMPLETE_VERSION_FOOTER", comment: ""))
           
            <<<  ButtonRow("remove") {
                $0.title = NSLocalizedString("BUY_COMPLETE_VERSION", comment: "")
                $0.cell.tintColor = UIColor.appGreenColor
                $0.hidden = Condition.function([], { form in
                    return Settings.sharedInstance.completeVersionPurchased
                })
                $0.disabled = Condition.function([], { form in
                    return !self.iapFetched
                })
            }.onCellSelection { (cell, row) in
                if self.iapFetched {
                    self.iapcontroller.products!.first!.buy()
                    self.deselectButtons()
                }
            }.cellUpdate { (cell, row) in
                if self.iapFetched {
                    row.title = String.localizedStringWithFormat(NSLocalizedString("BUY_COMPLETE_VERSION_WITH_PRICE", comment: ""), self.iapcontroller.products!.first!.priceFormatted!);
                }
            }
    
            <<< ButtonRow("restore") {
                $0.title = NSLocalizedString("RESTORE_COMPLETE_VERSION", comment: "")
                $0.cell.tintColor = UIColor.appGreenColor
                $0.hidden = Condition.function([], { form in
                    return Settings.sharedInstance.completeVersionPurchased
                })
                $0.disabled = Condition.function([], { form in
                    return !self.iapFetched
                })
            }.onCellSelection { (cell, row) in
                if self.iapFetched {
                    self.iapcontroller.restore()
                    self.deselectButtons()
                }
            }
        
            <<< ButtonRow("thanks") {
                $0.title = NSLocalizedString("THANKS_FOR_BUYING", comment: "")
                $0.cell.tintColor = UIColor.appGreenColor
                $0.disabled = true
                $0.hidden = Condition.function([], { form in
                    return !Settings.sharedInstance.completeVersionPurchased
                })
            }
        
            
            +++ Section(NSLocalizedString("INFORMATIONS", comment: ""))
        
            <<< TextAreaRow("disclaimer") {
                $0.value = NSLocalizedString("DISCLAIMER", comment: "")
                $0.disabled = true
            }
    }
    
    func updateForm() {
        self.form.allRows.forEach{ row in
            row.evaluateDisabled()
            row.evaluateHidden()
            row.updateCell()
        }
    }
    
    // MARK: Purchases
    
    func didFetchedProducts(_ sender: AnyObject) {
        iapFetched = true
        self.updateForm()
    }
    
    func didPurchasedProduct(_ sender: AnyObject) {
        iapFetched = false
        self.updateForm()
        Settings.sharedInstance.completeVersionPurchased = true
        
        let alert = UIAlertView(title: NSLocalizedString("THANK_YOU", comment: ""), message: NSLocalizedString("IAP_SUCCESS", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("DISMISS", comment: ""))
        alert.show()
    }
    
    func didFailedToPurchaseProduct(_ sender: AnyObject) {
        let alert = UIAlertView(title: NSLocalizedString("IAP_FAIL", comment: ""), message: NSLocalizedString("IAP_FAILURE_DESC", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("DISMISS", comment: ""))
        alert.show()
    }
}
