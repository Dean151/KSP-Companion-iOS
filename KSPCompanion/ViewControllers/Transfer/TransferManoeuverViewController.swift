//
//  TransferManoeuverViewController.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 09/06/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import UIKit

class TransferManoeuverViewController: TransferResultModalController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let results = self.results {
            // FIXME: View don't show properly on iPad
            let interplanetaryView = TransferManoeuverView(frame: self.view.bounds)
            
            interplanetaryView.fromName = results.from.name
            interplanetaryView.fromColor = results.from.color
            interplanetaryView.angle = CGFloat(results.ejectionAngle)
            interplanetaryView.toPrograde = results.to.orbit!.a > results.from.orbit!.a
            interplanetaryView.deltaV = results.deltaV
            
            self.view.addSubview(interplanetaryView)
        }
        
        // FIXME: Should detect and agree with orientation changes
    }
}
