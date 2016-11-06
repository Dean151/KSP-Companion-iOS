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
    case celsius=0, farenheit, kelvin
    
    var description: String {
        switch self {
        case .farenheit:
            return "Farenheit"
        case .kelvin:
            return "Kelvin"
        default:
            return "Celsius"
        }
    }
    
    var symbol: String {
        switch self {
        case .farenheit:
            return "°F"
        case .kelvin:
            return "K"
        default:
            return "°C"
        }
    }
    
    static var count: Int {
        var max: Int = 0
        while let _ = self.init(rawValue: max) { max += 1 }
        return max
    }
    
    func fromCelsius(_ celsius: Double) -> Double {
        switch self {
        case .kelvin:
            return celsius+287.15
        case .farenheit:
            return celsius*1.8+32
        default:
            return celsius
        }
    }
}

class Units {
    static func lengthUnit(_ length: Double, allowSubUnits: Bool) -> String {
        
        let preUnits = ["", "k"]
        var actualUnit = 0
        var newLength = length
        
        if allowSubUnits {
            while (newLength/1000 > 1 && actualUnit < preUnits.count-1) {
                newLength = length / 1000
                actualUnit += 1
            }
        }
        
        let roundedLength = newLength.format()
        return "\(roundedLength) \(preUnits[actualUnit])m"
    }
    
    static func timeUnit(_ time: Double) -> String {
        var seconds = round(time*10)/10
        var minutes = 0
        var hours = 0
        var days = 0
        var years = 0
        
        let minuteDuration:Double = 60
        let hourDuration = 60 * minuteDuration
        let dayDuration = (Settings.sharedInstance.useKerbinTime ? 6 : 24) * hourDuration
        let yearDuration = (Settings.sharedInstance.useKerbinTime ? 426 : 365) * dayDuration
        
        if seconds/yearDuration >= 1 {
            years = Int(floor( seconds/yearDuration ))
            seconds = seconds.truncatingRemainder(dividingBy: yearDuration)
        }
        
        if seconds/dayDuration >= 1 {
            days = Int(floor( seconds/dayDuration ))
            seconds = seconds.truncatingRemainder(dividingBy: dayDuration)
        }
        
        if seconds/hourDuration >= 1 {
            hours = Int(floor(seconds/hourDuration))
            seconds = seconds.truncatingRemainder(dividingBy: hourDuration)
        }
        
        if seconds/minuteDuration >= 1 {
            minutes = Int(floor(seconds/minuteDuration))
            seconds = seconds.truncatingRemainder(dividingBy: minuteDuration)
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
        
        if time == dayDuration && Settings.sharedInstance.useKerbinTime {
            return NSLocalizedString("DAY_DETAIL", comment: "")
        }
        
        if time == yearDuration && Settings.sharedInstance.useKerbinTime {
            return NSLocalizedString("YEAR_DETAIL", comment: "")
        }
        
        return out
    }
    
    static func pressureUnit(_ pressure: Double) -> String {
        let roundedPressure = pressure.format()
        return "\(roundedPressure) kPa"
    }
    
    static func temperatureUnit(celsius: Double, out: TemperatureUnit) -> String {
        return "\(out.fromCelsius(celsius))\(out.symbol)"
    }
    
    static func temperatureUnit(celsius: Double) -> String {
        return temperatureUnit(celsius: celsius, out: Settings.sharedInstance.temperatureUnit)
    }
}

extension Double {
    func format(_ f: Double) -> String {
        let nb = (self * pow(10, f)).rounded() / pow(10, f)
        return nb.format()
    }
    
    func format() -> String {
        let nf = NumberFormatter()
        nf.groupingSeparator = " "
        nf.numberStyle = NumberFormatter.Style.decimal
        return nf.string(from: NSNumber(value: self))!
    }
}
