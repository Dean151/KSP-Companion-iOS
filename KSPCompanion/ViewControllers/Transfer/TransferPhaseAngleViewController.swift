//
//  TransferResultsViewController.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 05/06/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import UIKit

class TransferPhaseAngleViewController: TransferResultModalController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let results = self.results {
            // FIXME: View don't show properly on iPad
            let interplanetaryView = TransferAnglePhaseView(frame: self.view.bounds)
            
            interplanetaryView.fromSemiMajorAxis = CGFloat(results.from.orbit!.a)
            interplanetaryView.toSemiMajorAxis = CGFloat(results.to.orbit!.a)
            interplanetaryView.parentColor = results.parent.color
            interplanetaryView.fromColor = results.from.color
            interplanetaryView.toColor = results.to.color
            interplanetaryView.calculatedAnglePhase = CGFloat(results.phaseAngle)
            
            self.view.addSubview(interplanetaryView)
        }
        
        // FIXME: Should detect and agree with orientation changes
    }
}
