//
//  Constants.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 30/05/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import Foundation
import Darwin

let gravitationalConstant = 6.674E-11

enum TemperatureUnit: Int, CustomStringConvertible {
    case Celsius=0, Farenheit, Kelvin
    
    var description: String {
        switch self {
        case .Farenheit:
            return "Farenheit"
        case .Kelvin:
            return "Kelvin"
        default:
            return "Celsius"
        }
    }
    
    var symbol: String {
        switch self {
        case .Farenheit:
            return "°F"
        case .Kelvin:
            return "K"
        default:
            return "°C"
        }
    }
    
    static var count: Int {
        var max: Int = 0
        while let _ = self.init(rawValue: ++max) {}
        return max
    }
    
    func fromCelsius(celsius: Double) -> Double {
        switch self {
        case .Kelvin:
            return celsius+287.15
        case .Farenheit:
            return celsius*1.8+32
        default:
            return celsius
        }
    }
}

class Units {
    static func lengthUnit(length: Double, allowSubUnits: Bool) -> String {
        
        let preUnits = ["", "k"]
        var actualUnit = 0
        var newLength = length
        
        if allowSubUnits {
            while (newLength/1000 > 1 && actualUnit < preUnits.count-1) {
                newLength = length / 1000
                actualUnit++
            }
        }
        
        let roundedLength = newLength.format()
        return "\(roundedLength) \(preUnits[actualUnit])m"
    }
    
    static func timeUnit(time: Double) -> String {
        var seconds = round(time*10)/10
        var minutes = 0
        var hours = 0
        var days = 0
        var years = 0
        
        let minuteDuration:Double = 60
        let hourDuration = 60 * minuteDuration
        let dayDuration = (SettingsManager.useKerbinTime ? 6 : 24) * hourDuration
        let yearDuration = (SettingsManager.useKerbinTime ? 426 : 365) * dayDuration
        
        if seconds/yearDuration >= 1 {
            years = Int(floor( seconds/yearDuration ))
            seconds = seconds%yearDuration
        }
        
        if seconds/dayDuration >= 1 {
            days = Int(floor( seconds/dayDuration ))
            seconds = seconds%dayDuration
        }
        
        if seconds/hourDuration >= 1 {
            hours = Int(floor(seconds/hourDuration))
            seconds = seconds%hourDuration
        }
        
        if seconds/minuteDuration >= 1 {
            minutes = Int(floor(seconds/minuteDuration))
            seconds = seconds%minuteDuration
        }
        
        seconds = round(seconds*10)/10
        
        var out = ""
        
        if years > 0 {
            out += String.localizedStringWithFormat(NSLocalizedString("YEAR_SUFFIX", comment: ""), years)
        }
        if days > 0 {
            out += String.localizedStringWithFormat(NSLocalizedString("DAY_SUFFIX", comment: ""), days)
        }
        if hours > 0 {
            out += " \(hours)h"
        }
        if minutes > 0 {
            out += " \(minutes)min"
        }
        if seconds > 0 {
            out += " \(seconds)s"
        }
        
        if time == dayDuration && SettingsManager.useKerbinTime {
            return NSLocalizedString("DAY_DETAIL", comment: "")
        }
        
        if time == yearDuration && SettingsManager.useKerbinTime {
            return NSLocalizedString("YEAR_DETAIL", comment: "")
        }
        
        return out
    }
    
    static func pressureUnit(pressure: Double) -> String {
        let roundedPressure = pressure.format()
        return "\(roundedPressure) kPa"
    }
    
    static func temperatureUnit(celsius celsius: Double, out: TemperatureUnit) -> String {
        return "\(out.fromCelsius(celsius))\(out.symbol)"
    }
    
    static func temperatureUnit(celsius celsius: Double) -> String {
        return temperatureUnit(celsius: celsius, out: SettingsManager.temperatureUnit)
    }
}

extension Double {
    func format(f: Double) -> String {
        let nb = round( self * pow(10, f) ) / pow(10, f)
            return nb.format()
    }
    
    func format() -> String {
        let nf = NSNumberFormatter()
        nf.groupingSeparator = " "
        nf.numberStyle = NSNumberFormatterStyle.DecimalStyle
        
        return nf.stringFromNumber(self)!
    }
}