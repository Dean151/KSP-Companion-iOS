//
//  SettingsManager.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 10/06/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import Foundation
import SecureNSUserDefaults

class Settings {
    
    let calculationLimit = 20
    
    // Names of the settings
    private let hideAdsString = "hideAds"
    private let lastCounterReinitDateString = "lastCounterReinitDate"
    private let counterString = "counter"
    private let solarSystemString = "solarSystem"
    private let temperatureUnitString = "temperatureUnit"
    private let earthTimeString = "useEarthTime"
    
    // Singleton
    static let sharedInstance = Settings()
    
    let settings = NSUserDefaults.standardUserDefaults()
    
    init() {
        guard let key = NSBundle.mainBundle().objectForInfoDictionaryKey("SecureNSUserDefaultKey") as? String else {
            fatalError("Could access encryption key")
        }
        
        settings.setSecret(key)
    }
    
    var canDoCalculation: Bool {
        if completeVersionPurchased {
            return true
        }
        
        let calendar = NSCalendar.currentCalendar()
        let flags: NSCalendarUnit = [.Hour, .Day, .Month, .Year]
        let comp1 = calendar.components(flags, fromDate: lastResetCounterDate)
        let comp2 = calendar.components(flags, fromDate: NSDate())
        
        if !(comp1.day == comp2.day && comp1.month == comp2.month && comp1.year == comp2.year) {
            numberOfCalculations = 0
            lastResetCounterDate = NSDate()
            return true
        }
        
        return numberOfCalculations < calculationLimit
    }
    
    var completeVersionPurchased: Bool {
        get {
            return settings.secretBoolForKey(hideAdsString)
        }
        set {
            settings.setSecretBool(newValue, forKey: hideAdsString)
        }
    }
    
    var numberOfCalculations: Int {
        get {
            return settings.secretIntegerForKey(counterString)
        }
        set {
            settings.setSecretInteger(newValue, forKey: counterString)
        }
    }
    
    private var lastResetCounterDate: NSDate {
        get {
            return NSDate(timeIntervalSince1970: settings.secretDoubleForKey(lastCounterReinitDateString))
        }
        set {
            settings.setSecretDouble(newValue.timeIntervalSince1970, forKey: lastCounterReinitDateString)
        }
    }
    
    var solarSystem: SolarSystem {
        get {
            guard completeVersionPurchased == true else {
                return SolarSystem.Kerbolian
            }
            
            if let solarsystem = SolarSystem(rawValue: settings.integerForKey(solarSystemString)) {
                return solarsystem
            } else {
                return SolarSystem.Kerbolian
            }
        }
        set {
            settings.setInteger(newValue.rawValue, forKey: solarSystemString)
        }
    }
    
    var temperatureUnit: TemperatureUnit {
        get {
            if let temp = TemperatureUnit(rawValue: settings.integerForKey(temperatureUnitString)) {
                return temp
            } else {
                return TemperatureUnit.Celsius
            }
        }
        set {
            settings.setInteger(newValue.rawValue, forKey: temperatureUnitString)
        }
    }
    
    var useEarthTime: Bool {
        get {
            return settings.boolForKey(earthTimeString)
        }
        set {
            settings.setBool(newValue, forKey: earthTimeString)
        }
    }
    
    var useKerbinTime: Bool {
        get {
            return !useEarthTime
        }
        set {
            useEarthTime = !newValue
        }
    }
}