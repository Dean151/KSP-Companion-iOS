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
    fileprivate let hideAdsString = "hideAds"
    fileprivate let lastCounterReinitDateString = "lastCounterReinitDate"
    fileprivate let counterString = "counter"
    fileprivate let solarSystemString = "solarSystem"
    fileprivate let temperatureUnitString = "temperatureUnit"
    fileprivate let earthTimeString = "useEarthTime"
    
    // Singleton
    static let sharedInstance = Settings()
    
    let settings = UserDefaults.standard
    
    init() {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SecureNSUserDefaultKey") as? String else {
            fatalError("Could access encryption key")
        }
        
        settings.setSecret(key)
    }
    
    var canDoCalculation: Bool {
        if completeVersionPurchased {
            return true
        }
        
        let calendar = Calendar.current
        let flags: NSCalendar.Unit = [.hour, .day, .month, .year]
        let comp1 = (calendar as NSCalendar).components(flags, from: lastResetCounterDate)
        let comp2 = (calendar as NSCalendar).components(flags, from: Date())
        
        if !(comp1.day == comp2.day && comp1.month == comp2.month && comp1.year == comp2.year) {
            numberOfCalculations = 0
            lastResetCounterDate = Date()
            return true
        }
        
        return numberOfCalculations < calculationLimit
    }
    
    var completeVersionPurchased: Bool {
        get {
            return settings.secretBool(forKey: hideAdsString)
        }
        set {
            settings.setSecretBool(newValue, forKey: hideAdsString)
        }
    }
    
    var numberOfCalculations: Int {
        get {
            return settings.secretInteger(forKey: counterString)
        }
        set {
            settings.setSecretInteger(newValue, forKey: counterString)
        }
    }
    
    fileprivate var lastResetCounterDate: Date {
        get {
            return Date(timeIntervalSince1970: settings.secretDouble(forKey: lastCounterReinitDateString))
        }
        set {
            settings.setSecretDouble(newValue.timeIntervalSince1970, forKey: lastCounterReinitDateString)
        }
    }
    
    var solarSystem: SolarSystem {
        get {
            guard completeVersionPurchased == true else {
                return SolarSystem.kerbolian
            }
            
            if let solarsystem = SolarSystem(rawValue: settings.integer(forKey: solarSystemString)) {
                return solarsystem
            } else {
                return SolarSystem.kerbolian
            }
        }
        set {
            settings.set(newValue.rawValue, forKey: solarSystemString)
        }
    }
    
    var temperatureUnit: TemperatureUnit {
        get {
            if let temp = TemperatureUnit(rawValue: settings.integer(forKey: temperatureUnitString)) {
                return temp
            } else {
                return TemperatureUnit.celsius
            }
        }
        set {
            settings.set(newValue.rawValue, forKey: temperatureUnitString)
        }
    }
    
    var useEarthTime: Bool {
        get {
            return settings.bool(forKey: earthTimeString)
        }
        set {
            settings.set(newValue, forKey: earthTimeString)
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
