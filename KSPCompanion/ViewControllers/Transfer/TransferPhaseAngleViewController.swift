//
//  TransferResultsViewController.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 05/06/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import UIKit

class TransferPhaseAngleViewController: TransferResultModalController {
    
    @IBOutlet weak var interplanetaryView: TransferAnglePhaseView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let results = self.results {
            self.interplanetaryView.fromSemiMajorAxis = CGFloat(results.from.orbit!.a)
            self.interplanetaryView.toSemiMajorAxis = CGFloat(results.to.orbit!.a)
            
            self.interplanetaryView.parentColor = results.parent.color
            self.interplanetaryView.fromColor = results.from.color
            self.interplanetaryView.toColor = results.to.color
            
            self.interplanetaryView.calculatedAnglePhase = CGFloat(results.phaseAngle)
        }
    }
}
