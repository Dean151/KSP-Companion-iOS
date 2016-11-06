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
        
        if self.navigationController != nil {
            self.navigationController!.topViewController!.title = NSLocalizedString("MANOEUVER", comment: "")
        }
        
        if let results = self.results {
            let interplanetaryView = TransferManoeuverView()
            
            interplanetaryView.fromName = results.from.name
            interplanetaryView.fromColor = results.from.color
            interplanetaryView.angle = CGFloat(results.ejectionAngle)
            interplanetaryView.toPrograde = results.to.orbit!.a > results.from.orbit!.a
            interplanetaryView.deltaV = results.deltaV
            
            self.subview = interplanetaryView
            self.view.addSubview(interplanetaryView)
        }
    }
}
