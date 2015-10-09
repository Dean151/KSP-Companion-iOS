//
//  SettingsViewController.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 24/09/2015.
//  Copyright © 2015 Thomas Durand. All rights reserved.
//

import UIKit
import IAPController
import Eureka

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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !SettingsManager.hideAds && !iapFetched {
            setupIAP()
        }
    }
    
    func deselectButtons() {
        if let index = tableView!.indexPathForSelectedRow {
            tableView!.deselectRowAtIndexPath(index, animated: true)
        }
    }
    
    func setupIAP() {
        iapcontroller.fetchProducts()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFetchedProducts:", name: IAPControllerFetchedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didPurchasedProduct:", name: IAPControllerPurchasedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFailedToPurchaseProduct:", name: IAPControllerFailedNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setupForm() {
        form.removeAll()
        
        form +++
            Section(header: HeaderFooterView<UIView>(stringLiteral: NSLocalizedString("SETTINGS", comment: "")), footer: HeaderFooterView<UIView>(stringLiteral: NSLocalizedString("SETTINGS_FOOTER", comment: "")))
            
            <<< SegmentedRow<String>("temperature") {
                $0.title = NSLocalizedString("TEMPERATURE_UNIT", comment: "")
                $0.options = self.tempOptions
                $0.value = self.tempOptions[SettingsManager.temperatureUnit.rawValue]
            }.onChange { row in
                guard let tempString = row.value else { return }
                guard let temp = TemperatureUnit(rawValue: self.tempOptions.indexOf(tempString)!) else { return }
                SettingsManager.temperatureUnit = temp
            }
            
            <<< SwitchRow("time") {
                $0.title = NSLocalizedString("KERBIN_TIME_UNITS", comment: "")
                $0.value = SettingsManager.useKerbinTime
            }.onChange { row in
                    guard let kerbinTime = row.value else { return }
                    SettingsManager.useKerbinTime = kerbinTime
            }
            
        
            +++ Section(header: HeaderFooterView<UIView>(stringLiteral: NSLocalizedString("ADS", comment: "")), footer: HeaderFooterView<UIView>(stringLiteral: NSLocalizedString("ADS_FOOTER", comment: "")))
           
            <<<  ButtonRow("remove") {
                $0.title = NSLocalizedString("REMOVE_ADS", comment: "")
                $0.cell.tintColor = UIColor.appGreenColor
                $0.hidden = Condition.Function([], { form in
                    return SettingsManager.hideAds
                })
                $0.disabled = Condition.Function([], { form in
                    return !self.iapFetched
                })
            }.onCellSelection { (cell, row) in
                if self.iapFetched {
                    self.iapcontroller.products!.first!.buy()
                    self.deselectButtons()
                }
            }.cellUpdate { (cell, row) in
                if self.iapFetched {
                    row.title = String.localizedStringWithFormat(NSLocalizedString("REMOVE_ADS_WITH_PRICE", comment: ""), self.iapcontroller.products!.first!.priceFormatted!);
                }
            }
    
            <<< ButtonRow("restore") {
                $0.title = NSLocalizedString("RESTORE_ADS", comment: "")
                $0.cell.tintColor = UIColor.appGreenColor
                $0.hidden = Condition.Function([], { form in
                    return SettingsManager.hideAds
                })
                $0.disabled = Condition.Function([], { form in
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
                $0.hidden = Condition.Function([], { form in
                    return !SettingsManager.hideAds
                })
            }
        
            
            +++ Section(HeaderFooterView<UIView>(stringLiteral: NSLocalizedString("INFORMATIONS", comment: "")))
        
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
    
    func didFetchedProducts(sender: AnyObject) {
        iapFetched = true
        self.updateForm()
    }
    
    func didPurchasedProduct(sender: AnyObject) {
        iapFetched = false
        self.updateForm()
        SettingsManager.hideAds = true
        
        NSNotificationCenter.defaultCenter().postNotificationName(BannerShouldBeHiddenByIAP, object: nil)
        
        let alert = UIAlertView(title: NSLocalizedString("THANK_YOU", comment: ""), message: NSLocalizedString("IAP_SUCCESS", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("DISMISS", comment: ""))
        alert.show()
    }
    
    func didFailedToPurchaseProduct(sender: AnyObject) {
        let alert = UIAlertView(title: NSLocalizedString("IAP_FAIL", comment: ""), message: NSLocalizedString("IAP_FAILURE_DESC", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("DISMISS", comment: ""))
        alert.show()
    }
}