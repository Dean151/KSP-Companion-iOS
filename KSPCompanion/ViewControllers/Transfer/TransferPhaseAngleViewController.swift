//
//  TransferResultsViewController.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 05/06/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import UIKit
import SnapKit

class TransferPhaseAngleViewController: TransferResultModalController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let results = self.results {
            let interplanetaryView = TransferAnglePhaseView()
            
            interplanetaryView.fromSemiMajorAxis = CGFloat(results.from.orbit!.a)
            interplanetaryView.toSemiMajorAxis = CGFloat(results.to.orbit!.a)
            interplanetaryView.parentColor = results.parent.color
            interplanetaryView.fromColor = results.from.color
            interplanetaryView.toColor = results.to.color
            interplanetaryView.calculatedAnglePhase = CGFloat(results.phaseAngle)
            
            self.subview = interplanetaryView
            self.view.addSubview(interplanetaryView)
            
            // Constraints
            interplanetaryView.snp_makeConstraints(closure: { (make) -> Void in
                make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, 0, 0))
            })
        }
    }
}
