//
//  Atmosphere.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 01/06/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import Foundation

class Atmosphere {
    var surfacePressure: Double
    var scaleHeight: Double
    var limitAltitude: Double
    var temperatureMin: Double
    var temperatureMax: Double
    var hasOxygen: Bool
    
    init(surfacePressure: Double, scaleHeight: Double, limitAltitude: Double, temperatureMin: Double, temperatureMax: Double, hasOxygen: Bool) {
        self.surfacePressure = surfacePressure
        self.scaleHeight = scaleHeight
        self.limitAltitude = limitAltitude
        self.temperatureMin = temperatureMin
        self.temperatureMax = temperatureMax
        self.hasOxygen = hasOxygen
    }
}