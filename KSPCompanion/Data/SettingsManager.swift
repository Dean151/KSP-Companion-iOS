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
    
    // Names of the settings
    private let hideAdsString = "hideAds"
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
    
    var hideAds: Bool {
        get {
            return settings.secretBoolForKey(hideAdsString)
        }
        set {
            settings.setSecretBool(newValue, forKey: hideAdsString)
        }
    }
    
    var solarSystem: SolarSystem {
        get {
            guard hideAds == true else {
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