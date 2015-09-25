//
//  SettingsViewController.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 24/09/2015.
//  Copyright © 2015 Thomas Durand. All rights reserved.
//

import UIKit
import IAPController
import XLForm

class SettingsViewController: XLFormViewController {
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
        if let index = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(index, animated: true)
        }
    }
    
    func setupIAP() {
        iapcontroller.fetchProducts()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFetchedProducts:", name: IAPControllerFetchedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didPurchasedProduct:", name: IAPControllerPurchasedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFailedToPurchaseProduct:", name: IAPControllerFailedNotification, object: nil)
    }
    
    // MARK: XLForm
    
    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        switch formRow.tag! {
        case "temperature":
            if let tempString = newValue as? String {
                if let temp = TemperatureUnit(rawValue: tempOptions.indexOf(tempString)!) {
                    SettingsManager.temperatureUnit = temp
                }
            }
        case "time":
            if let kerbinTime = newValue as? Bool {
                SettingsManager.useKerbinTime = kerbinTime
            }
        default:
            break
        }
        
    }
    
    func setupForm() {
        let form = XLFormDescriptor()
        
        var section = XLFormSectionDescriptor()
        section.title = NSLocalizedString("SETTINGS", comment: "")
        section.footerTitle = NSLocalizedString("SETTINGS_FOOTER", comment: "")
        
        var row = XLFormRowDescriptor(tag: "temperature", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: NSLocalizedString("TEMPERATURE_UNIT", comment: ""))
        row.selectorOptions = tempOptions
        row.value = tempOptions[SettingsManager.temperatureUnit.rawValue]
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "time", rowType: XLFormRowDescriptorTypeBooleanSwitch, title: NSLocalizedString("KERBIN_TIME_UNITS", comment: ""))
        row.value = SettingsManager.useKerbinTime
        section.addFormRow(row)
        
        form.addFormSection(section)
        
        section = XLFormSectionDescriptor()
        section.title = NSLocalizedString("ADS", comment: "")
        section.footerTitle = NSLocalizedString("ADS_FOOTER", comment: "")
        
        if !SettingsManager.hideAds {
            row = XLFormRowDescriptor(tag: "remove", rowType: XLFormRowDescriptorTypeButton, title: NSLocalizedString("REMOVE_ADS", comment: ""))
            if iapFetched {
                row.title = String.localizedStringWithFormat(NSLocalizedString("REMOVE_ADS_WITH_PRICE", comment: ""), iapcontroller.products!.first!.priceFormatted!);
                row.action.formBlock = { Void in
                    self.iapcontroller.products!.first!.buy()
                    self.deselectButtons()
                }
            } else {
                row.disabled = true
            }
            section.addFormRow(row)
            
            row = XLFormRowDescriptor(tag: "restore", rowType: XLFormRowDescriptorTypeButton, title: NSLocalizedString("RESTORE_ADS", comment: ""))
            if iapFetched {
                row.action.formBlock = { Void in
                    self.iapcontroller.restore()
                    self.deselectButtons()
                }
            } else {
                row.disabled = true
            }
            section.addFormRow(row)
        } else {
            row = XLFormRowDescriptor(tag: "thanks", rowType: XLFormRowDescriptorTypeButton, title: NSLocalizedString("THANKS_FOR_BUYING", comment: ""))
            row.disabled = true
            section.addFormRow(row)
        }
        
        form.addFormSection(section)
        
        section = XLFormSectionDescriptor()
        section.title = NSLocalizedString("INFORMATIONS", comment: "")
        
        row = XLFormRowDescriptor(tag: "disclaimer", rowType: XLFormRowDescriptorTypeTextView)
        row.value = NSLocalizedString("DISCLAIMER", comment: "")
        row.disabled = true
        section.addFormRow(row)
        
        form.addFormSection(section)
        
        self.form = form
    }
    
    // MARK: Purchases
    
    func didFetchedProducts(sender: AnyObject) {
        iapFetched = true
        setupForm()
    }
    
    func didPurchasedProduct(sender: AnyObject) {
        iapFetched = false
        setupForm()
        SettingsManager.hideAds = true
        
        let alert = UIAlertView(title: NSLocalizedString("THANK_YOU", comment: ""), message: NSLocalizedString("IAP_SUCCESS", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("DISMISS", comment: ""))
        alert.show()
    }
    
    func didFailedToPurchaseProduct(sender: AnyObject) {
        let alert = UIAlertView(title: NSLocalizedString("IAP_FAIL", comment: ""), message: NSLocalizedString("IAP_FAILURE_DESC", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("DISMISS", comment: ""))
        alert.show()
    }
}