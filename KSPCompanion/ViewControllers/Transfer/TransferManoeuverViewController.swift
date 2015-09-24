//
//  TransferManoeuverViewController.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 09/06/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import UIKit

class TransferManoeuverViewController: TransferResultModalController {
    
    @IBOutlet weak var interplanetaryView: TransferManoeuverView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let results = self.results {
            self.interplanetaryView.fromName = results.from.name
            self.interplanetaryView.fromColor = results.from.color
            self.interplanetaryView.angle = CGFloat(results.ejectionAngle)
            self.interplanetaryView.toPrograde = results.to.orbit!.a > results.from.orbit!.a
            self.interplanetaryView.deltaV = results.deltaV
        }
    }
}
