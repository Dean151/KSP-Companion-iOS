//
//  DataManager.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 30/05/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import Foundation
import SwiftyJSON

enum SolarSystem: Int, CustomStringConvertible {
    case Kerbolian=0, OuterPlanets, KerbolPlus
    
    var fileName: String {
        switch self {
        case .Kerbolian:
            return "System"
        case .OuterPlanets:
            return "OuterPlanets"
        case .KerbolPlus:
            return "KerbolPlus"
        }
    }
    
    var description: String {
        switch self {
        case .Kerbolian:
            return NSLocalizedString("KERBAL_SYSTEM", comment: "")
        case .OuterPlanets:
            return NSLocalizedString("OUTERPLANET_SYSTEM", comment: "")
        case .KerbolPlus:
            return NSLocalizedString("KERBOL_PLUS_SYSTEM", comment: "")
        }
    }
    
    static var count: Int {
        return 3
    }
}

class DataManager {
    
    /*
        Fetching JSON and returning NSData
    */
    static func getJsonData(file file: String) -> NSData? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "json") {
            do {
                let data: NSData = try NSData(contentsOfFile: path, options: NSDataReadingOptions())
                return data
            } catch let error as NSError {
                print("Could not read \(file) json file with error \(error)")
                return nil
            }
        } else {
            print("\(file) json file not found")
            return nil
        }
    }
    
    
    /*
        Opening the JSON with Swiftyjson
    */
    static func getCelestialsFromJson() -> [Celestial] {
        var celestials = [Celestial]()
        
        // Fetching and populating celestials from json
        if let data = DataManager.getJsonData(file: Settings.sharedInstance.solarSystem.fileName) {
            var error: NSError?
            let json = JSON(data: data, options: NSJSONReadingOptions(), error: &error)
            
            celestials = getCelestials(json)
        }
        
        return celestials
    }
    
    /*
        Browsing in the tree to fetch all celestials
    */
    static func getCelestials(json: JSON) -> [Celestial] {
        return getCelestials(json, parent: nil, out: [Celestial]())
    }
    
    static func getCelestials(json: JSON, parent: Celestial?, out: [Celestial]) -> [Celestial] {
        var celestials = out
        
        for (_, subjson): (String, JSON) in json {
            if let celestial = getCelestial(subjson, parent: parent) {
                celestials.append(celestial)
            
                let subsubjson = subjson["celestials"]
                celestials = getCelestials(subsubjson, parent: celestial, out: celestials)
            }
        }
        
        return celestials
    }
    
    /*
        Getting specific celestial (leaf)
    */
    static func getCelestial(subjson: JSON, parent: Celestial?) -> Celestial? {
        var celestial: Celestial?
        var orbit: Orbit?
        var atmosphere: Atmosphere?
        
        if let orbitJson = subjson["orbit"].dictionary {
            if let _ = orbitJson["semiMajorAxis"]?.double {
                orbit = Orbit(
                    orbitAround: parent!,
                    semiMajorAxis: orbitJson["semiMajorAxis"]!.doubleValue,
                    eccentricity: orbitJson["eccentricity"]!.doubleValue,
                    periapsisArgument: orbitJson["periapsisArgument"]!.doubleValue,
                    meanAnomaly: orbitJson["meanAnomaly"]!.doubleValue,
                    atTime: orbitJson["epoch"]?.int,
                    inclination: orbitJson["inclination"]!.doubleValue,
                    ascendingNodeLongitude: orbitJson["ascendingNodeLongitude"]!.doubleValue)
            } else {
                orbit = Orbit(
                    orbitAround: parent!,
                    apoapsis: orbitJson["apoapsis"]!.doubleValue,
                    periapsis: orbitJson["periapsis"]!.doubleValue,
                    periapsisArgument: orbitJson["periapsisArgument"]!.doubleValue,
                    meanAnomaly: orbitJson["meanAnomaly"]!.doubleValue,
                    atTime: orbitJson["epoch"]?.int,
                    inclination: orbitJson["inclination"]!.doubleValue,
                    ascendingNodeLongitude: orbitJson["ascendingNodeLongitude"]!.doubleValue)
            }
        }
        if let atmosphereJson = subjson["atmosphere"].dictionary {
            atmosphere = Atmosphere(
                surfacePressure: atmosphereJson["surfacePressure"]!.doubleValue,
                scaleHeight: atmosphereJson["scaleHeight"]!.doubleValue,
                limitAltitude: atmosphereJson["atmosphereLimit"]!.doubleValue,
                temperatureMin: atmosphereJson["temperatureMin"]!.doubleValue,
                temperatureMax: atmosphereJson["temperatureMax"]!.doubleValue,
                hasOxygen: atmosphereJson["haveOxygen"]!.boolValue)
        }
        
        // Mass geeOnSurface
        if let mass = subjson["mass"].double {
            celestial = Celestial(
                name: subjson["name"].stringValue,
                type: CelestialType.fromString(subjson["type"].stringValue),
                mass: mass,
                radius: subjson["radius"].doubleValue,
                rotationPeriod: subjson["rotationPeriod"].doubleValue,
                orbit: orbit,
                atmosphere: atmosphere)
        }
        
        if let gee = subjson["geeASL"].double {
            celestial = Celestial(
                name: subjson["name"].stringValue,
                type: CelestialType.fromString(subjson["type"].stringValue),
                radius: subjson["radius"].doubleValue,
                geeASL: gee,
                rotationPeriod: subjson["rotationPeriod"].doubleValue,
                orbit: orbit,
                atmosphere: atmosphere)
        }
        
        guard let cel = celestial else { return nil }
        
        if let color = subjson["color"].string {
            cel.assignColor(color)
        }
        
        return cel
    }
}