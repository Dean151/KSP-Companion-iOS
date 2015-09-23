//
//  DataManager.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 30/05/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import Foundation
import SwiftyJSON

enum SolarSystem: Int {
    case Kerbolian=0, OuterPlanets
    
    var fileName: String {
        switch self {
        case .Kerbolian:
            return "System"
        case .OuterPlanets:
            return "OuterPlanets"
        }
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
        if let data = DataManager.getJsonData(file: SettingsManager.solarSystem.fileName) {
            var error: NSError?
            let json = JSON(data: data, options: NSJSONReadingOptions(), error: &error)
            
            celestials = getCelestials(json)
        }
        
        return celestials
    }
    
    /*
        Browsing in the tree
    */
    static func getCelestials(json: JSON) -> [Celestial] {
        return getCelestials(json, parent: nil, out: [Celestial]())
    }
    
    static func getCelestials(json: JSON, parent: Celestial?, out: [Celestial]) -> [Celestial] {
        var celestials = out
        
        for (_, subjson): (String, JSON) in json {
            let celestial = getCelestial(subjson, parent: parent)
            celestials.append(celestial)
            
            let subsubjson = subjson["celestials"]
            celestials = getCelestials(subsubjson, parent: celestial, out: celestials)
        }
        
        return celestials
    }
    
    /*
        Getting specific celestial
    */
    static func getCelestial(subjson: JSON, parent: Celestial?) -> Celestial {
        var celestial: Celestial
        var orbit: Orbit? = nil
        var atmosphere: Atmosphere? = nil
        
        if let orbitJson = subjson["orbit"].dictionary {
            orbit = Orbit(
                orbitAround: parent!,
                apoapsis: orbitJson["apoapsis"]!.doubleValue,
                periapsis: orbitJson["periapsis"]!.doubleValue,
                periapsisArgument: orbitJson["periapsisArgument"]!.doubleValue,
                meanAnomaly: orbitJson["meanAnomaly"]!.doubleValue,
                inclination: orbitJson["inclination"]!.doubleValue,
                ascendingNodeLongitude: orbitJson["ascendingNodeLongitude"]!.doubleValue)
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
        
        celestial = Celestial(
            name: subjson["name"].stringValue,
            type: CelestialType.fromString(subjson["type"].stringValue),
            mass: subjson["mass"].doubleValue,
            radius: subjson["radius"].doubleValue,
            rotationPeriod: subjson["rotationPeriod"].doubleValue,
            orbit: orbit,
            atmosphere: atmosphere)
        
        if let color = subjson["color"].string {
            celestial.assignColor(color)
        }
        
        return celestial
    }
}