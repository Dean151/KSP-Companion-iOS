//
//  Orbit.swift
//  KSP Calculator
//
//  Created by Thomas Durand on 29/05/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import Foundation
import Darwin

class Orbit {
    var orbitAroundCelestial: Celestial

    var periapsis: Double
    var apoapsis: Double
    var inclination: Double
    var periapsisArgument: Double
    var ascendingNodeLongitude: Double
    var meanAnomaly: Double
    
    init(orbitAround: Celestial, apoapsis: Double, periapsis: Double, periapsisArgument: Double, meanAnomaly: Double, atTime: Int?, inclination: Double, ascendingNodeLongitude: Double) {
        self.orbitAroundCelestial = orbitAround
        
        self.periapsis = periapsis
        self.apoapsis = apoapsis
        self.periapsisArgument = periapsisArgument
        
        self.inclination = inclination
        self.ascendingNodeLongitude = ascendingNodeLongitude
        
        if let atTime = atTime {
            // Should calculate the anomaly at time 0
            self.meanAnomaly = meanAnomaly
        } else {
            self.meanAnomaly = meanAnomaly
        }
    }
    
    convenience init(orbitAround: Celestial, semiMajorAxis: Double, eccentricity: Double, periapsisArgument: Double, meanAnomaly: Double, atTime: Int?, inclination: Double, ascendingNodeLongitude: Double) {
        let apoapsis = semiMajorAxis * (1+eccentricity)
        let periapsis = semiMajorAxis * (1-eccentricity)
        self.init(orbitAround: orbitAround, apoapsis: apoapsis, periapsis: periapsis, periapsisArgument: periapsisArgument, meanAnomaly: meanAnomaly, atTime: atTime, inclination: inclination, ascendingNodeLongitude: ascendingNodeLongitude)
    }
    
    convenience init(orbitAround: Celestial, apoapsis: Double, periapsis: Double, periapsisArgument: Double, meanAnomaly: Double, inclination: Double, ascendingNodeLongitude: Double) {
        self.init(orbitAround: orbitAround, apoapsis: apoapsis, periapsis: periapsis, periapsisArgument: periapsisArgument, meanAnomaly: meanAnomaly, atTime: nil, inclination: inclination, ascendingNodeLongitude: ascendingNodeLongitude)
    }
    
    convenience init(apoapsis: Double, periapsis: Double) {
        let cel = Celestial(name: "...", type: .Star, mass: 1, radius: 1, rotationPeriod: 1)
        self.init(orbitAround: cel, apoapsis: apoapsis, periapsis: periapsis, periapsisArgument: 0, meanAnomaly: 0, atTime: nil, inclination: 0, ascendingNodeLongitude: 0)
    }
    
    convenience init(orbitAround: Celestial, apoapsis: Double, periapsis: Double) {
        self.init(orbitAround: orbitAround, apoapsis: apoapsis, periapsis: periapsis, periapsisArgument: 0, meanAnomaly: 0, atTime: nil, inclination: 0, ascendingNodeLongitude: 0)
    }
    
    var apoapsisAltitude: Double {
        return apoapsis - orbitAroundCelestial.radius
    }
    
    var periapsisAltitude: Double {
        return periapsis - orbitAroundCelestial.radius
    }
    
    var apoapsisArgument: Double {
        return (180 + periapsisArgument)%360
    }
    
    var descendingNodeLongitude: Double {
        return (180 + ascendingNodeLongitude)%360
    }
    
    var orbitalPeriod: Double {
        return 2 * M_PI * sqrt( pow(a, 3) / ( orbitAroundCelestial.stdGravitationalParameter ) )
    }
    
    func velocityAtRadius(radius: Double) -> Double {
        return sqrt(orbitAroundCelestial.stdGravitationalParameter * ( 2/radius - 1/a) )
    }
    
    var periapsisVelocity: Double {
        return velocityAtRadius(periapsis)
    }
    
    var apoapsisVelocity: Double {
        return velocityAtRadius(apoapsis)
    }
    
    var isCircular: Bool {
        return periapsis == apoapsis
    }
    
    var a: Double {
        return (apoapsis + periapsis) / 2 //+ orbitAroundCelestial.radius
    }
    
    var b: Double {
        return sqrt(pow(a, 2) - pow(c,2))
    }
    
    var c: Double {
        return (apoapsis - periapsis) / 2
    }
    
    var eccentricity: Double {
        return c / a
    }
}