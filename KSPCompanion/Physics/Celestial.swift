//
//  Celestial.swift
//  KSP Calculator
//
//  Created by Thomas Durand on 29/05/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import Foundation
import UIKit
import Darwin

enum CelestialType: Int, CustomStringConvertible {
    case Star=0, Planet, RingPlanet, DwarfPlanet, Satellite, Comet, Other
    
    var image: UIImage? {
        switch self {
        case .Star:
            return UIImage(named: "star")
        case .Planet:
            return UIImage(named: "planet")
        case .RingPlanet:
            return UIImage(named: "ringplanet")
        case .DwarfPlanet:
            return UIImage(named: "dwarfplanet")
        case .Satellite:
            return UIImage(named: "satellite")
        case .Comet:
            return UIImage(named: "comet")
        default:
            return nil
        }
    }
    
    var description: String {
        switch self {
        case .Star:
            return "Star"
        case .Planet:
            return "Planet"
        case .RingPlanet:
            return "Ring Planet"
        case .DwarfPlanet:
            return "Dwarf Planet"
        case .Satellite:
            return "Natural satellite"
        case .Comet:
            return "Comet"
        default:
            return "Other"
        }
    }
    
    static func fromString(type: String) -> CelestialType {
        switch type {
        case "star":
            return .Star
        case "satellite":
            return .Satellite
        case "planet":
            return .Planet
        case "ringplanet":
            return .RingPlanet
        case "dwarfplanet":
            return .DwarfPlanet
        case "comet":
            return .Comet
        default:
            return .Other
        }
    }
}

class Celestial: Equatable, CustomStringConvertible {
    var name: String
    var color: UIColor
    var type: CelestialType
    
    var mass: Double
    var radius: Double
    
    var rotationPeriod: Double
    
    var orbit: Orbit?
    var atmosphere: Atmosphere?
    
    init(name: String, type: CelestialType, mass: Double, radius: Double, rotationPeriod: Double, orbit: Orbit?, atmosphere: Atmosphere?) {
        self.name = name
        self.color = UIColor.whiteColor()
        self.type = type
        self.mass = mass
        self.radius = radius
        self.rotationPeriod = rotationPeriod
        self.orbit = orbit
        self.atmosphere = atmosphere
    }
    
    convenience init(name: String, type: CelestialType, radius: Double, geeASL: Double, rotationPeriod: Double, orbit: Orbit?, atmosphere: Atmosphere?) {
        
        let calculatedMass = geeASL * pow(radius, 2) / gravitationalConstant
        self.init(name: name, type: type, mass: calculatedMass, radius: radius, rotationPeriod: rotationPeriod, orbit: orbit, atmosphere: atmosphere)
    }
    
    var description: String {
        return "\(self.name)"
    }
    
    convenience init(name: String, type: CelestialType, mass: Double, radius: Double, rotationPeriod: Double, orbit: Orbit?) {
        self.init(name: name, type: type, mass: mass, radius: radius, rotationPeriod: rotationPeriod, orbit: orbit, atmosphere: nil)
    }
    
    convenience init(name: String, type: CelestialType, mass: Double, radius: Double, rotationPeriod: Double) {
        self.init(name: name, type: type, mass: mass, radius: radius, rotationPeriod: rotationPeriod, orbit: nil)
    }
    
    // Color comes in "255,255,180" format
    func assignColor(rgb: String) {
        
        var colors = rgb.characters.split {$0 == ","}.map { String($0) }
        
        let red: CGFloat = CGFloat((colors[0] as NSString).floatValue)/255
        let green: CGFloat = CGFloat((colors[1] as NSString).floatValue)/255
        let blue: CGFloat = CGFloat((colors[2] as NSString).floatValue)/255
        
        self.color = UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    var surface: Double {
        return 4 * M_PI * pow(radius, 2)
    }
    
    var volume: Double {
        return (4/3) * M_PI * pow(radius, 3)
    }
    
    var density: Double {
        return mass / volume
    }
    
    var stdGravitationalParameter: Double {
        return  mass * gravitationalConstant
    }
    
    var surfaceGravity: Double {
        return gravityAtAltitude(0)
    }
    
    var surfaceEscapeVelocity: Double {
        return escapeVelocityAtAltitude(0)
    }
    
    var sphereOfInfluence: Double {
        if orbit != nil {
            return orbit!.a * pow( mass / orbit!.orbitAroundCelestial.mass , 2/5)
        } else {
            return Double.infinity
        }
    }
    
    func gravityAtRadius(radius: Double) -> Double {
        return stdGravitationalParameter / pow(radius, 2)
    }
    
    func gravityAtAltitude(altitude: Double) -> Double {
        return gravityAtRadius(radius + altitude)
    }
    
    func escapeVelocityAtRadius(radius: Double) -> Double {
        return sqrt(2 * stdGravitationalParameter / radius)
    }
    
    func escapeVelocityAtAltitude(altitude: Double) -> Double {
        return escapeVelocityAtRadius(altitude + radius)
    }
    
    func orbitVelocityAtRadius(radius: Double) -> Double {
        return sqrt(stdGravitationalParameter / radius)
    }
    
    func orbitVelocityAtAltitude(altitude: Double) -> Double {
        return orbitVelocityAtRadius(radius + altitude)
    }
    
    var synchronousOrbitRadius: Double {
        return pow( stdGravitationalParameter * pow(rotationPeriod, 2.0) / (4.0 * pow(M_PI, 2)) , 1.0/3.0 )
    }
    
    var synchronousOrbitAltitude: Double {
        return synchronousOrbitRadius - radius
    }
    
    var canGeoSync: Bool {
        return synchronousOrbitAltitude < sphereOfInfluence
    }
    
    var semiSynchronousOrbitRadius: Double {
        return pow(1.0/4.0, 1.0/3.0) * synchronousOrbitRadius;
    }
    
    var semiSynchronousOrbitAltitude: Double {
        return semiSynchronousOrbitRadius - radius
    }
    
    var canSemiGeoSync: Bool {
        return semiSynchronousOrbitAltitude < sphereOfInfluence
    }
    
    // Should be called from origin object
    func transfertTo(destination: Celestial, withAltitude: Double) -> (parent: Celestial, from: Celestial, to: Celestial, phaseAngle: Double, ejectionAngle: Double, ejectionSpeed: Double, deltaV: Double)? {
        return transfertTo(destination, withRadius: self.radius + withAltitude)
    }
    
    func transfertTo(destination: Celestial, withRadius: Double) -> (parent: Celestial, from: Celestial, to: Celestial, phaseAngle: Double, ejectionAngle: Double, ejectionSpeed: Double, deltaV: Double)? {
        
        if (self.orbit!.orbitAroundCelestial == destination.orbit!.orbitAroundCelestial && self != destination) {
            
            // Phase angle
            let phaseAngle = 180 * (1 - sqrt( 1/8 * pow( 1 + self.orbit!.a / destination.orbit!.a , 3) ) ) % 360
            
            let soi = self.sphereOfInfluence
            let µ = self.stdGravitationalParameter
            
            // Ejection speed
            let exitAlt = self.orbit!.a + soi // Approximation
            let v2 = sqrt(self.orbit!.orbitAroundCelestial.stdGravitationalParameter / exitAlt) * (sqrt(( 2 * destination.orbit!.a) / (exitAlt + destination.orbit!.a)) - 1)
            let ejectionSpeed = sqrt( (withRadius * (soi * pow(v2, 2) - 2 * µ) + 2 * soi * µ) ) / sqrt( (withRadius * soi) )
            
            // ∆V for manoeuver
            let deltaV = ejectionSpeed - orbitVelocityAtRadius(withRadius)
            
            // Ejection angle
            var ejectionAngle: Double = 0
            
            let eta = pow(ejectionSpeed, 2) / 2 - µ / withRadius
            let h = withRadius * ejectionSpeed
            let e = sqrt( 1 + ( ( 2 * eta * pow(h, 2) ) / pow(µ, 2) ) )
            
            if e < 1 {
                let a = -µ / (2 * eta)
                let l = a * (1 - pow(e, 2))
                let nu = acos( (l - soi) / (e * soi) )
                let phi = atan2((e * sin(nu)), (1 + e * cos(nu)))
                
                ejectionAngle = (90 - (phi * 180 / M_PI) + (nu * 180/M_PI)) % 360;
            } else {
                ejectionAngle = (180 - (acos(1 / e) * (180 / M_PI))) % 360;
            }
            
            return (destination.orbit!.orbitAroundCelestial, self, destination, phaseAngle, ejectionAngle, ejectionSpeed, deltaV)
        }
        
        return nil
    }
    
    func distributeSatellitesAtRadius(radius: Double, f: Double) -> Double? {
        return (2 * pow(f, 2/3) - 1) * radius - self.radius
    }
    
    func distributeSatellitesAtRadius(radius: Double, numberOfSatellites: Int) -> Double? {
        if (numberOfSatellites > 1) {
            var f:Double = (Double(numberOfSatellites)-1) / Double(numberOfSatellites)
            let per = distributeSatellitesAtRadius(radius, f: f)
            if let atmo = self.atmosphere {
                if per > atmo.limitAltitude {
                    return per
                }
            } else if per > 0 {
                return per
            }
            
            // Else we do a burn to a higher altitude
            f = (Double(numberOfSatellites)+1) / Double(numberOfSatellites)
            let apo = distributeSatellitesAtRadius(radius, f: f)
            if apo < self.sphereOfInfluence {
                return apo
            } else {
                return Double.infinity
            }
        } else {
            return nil
        }
    }
    
    func distributeSatellitesAtAltitude(altitude: Double, numberOfSatellites: Int) -> Double? {
        return distributeSatellitesAtRadius(altitude + radius, numberOfSatellites: numberOfSatellites)
    }
}
func ==(lhs: Celestial, rhs: Celestial) -> Bool {
    return lhs.name == rhs.name
}