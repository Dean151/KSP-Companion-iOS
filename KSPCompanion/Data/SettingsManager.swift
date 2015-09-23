//
//  SettingsManager.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 10/06/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import Foundation

class SettingsManager {
    
    // Names of the settings
    static let hideAdsString = "hideAds"
    static let temperatureUnitString = "temperatureUnit"
    static let earthTimeString = "useEarthTime"
    
    static var settings = NSUserDefaults.standardUserDefaults()
    
    static var hideAds: Bool {
        get {
            return settings.boolForKey(hideAdsString)
        }
        set {
            settings.setBool(newValue, forKey: hideAdsString)
        }
    }
    
    static var temperatureUnit: TemperatureUnit {
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
    
    static var useEarthTime: Bool {
        get {
            return settings.boolForKey(earthTimeString)
        }
        set {
            settings.setBool(newValue, forKey: earthTimeString)
        }
    }
    
    static var useKerbinTime: Bool {
        get {
            return !useEarthTime
        }
        set {
            useEarthTime = !newValue
        }
    }
}