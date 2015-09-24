//
//  TransferResultModalController.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 09/06/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import UIKit

class TransferResultModalController: UIViewController {
    
    var subview: UIView?
    
    var results: (parent: Celestial, from: Celestial, to: Celestial, phaseAngle: Double, ejectionAngle: Double, ejectionSpeed: Double, deltaV: Double)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
        
        let dismissButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("dismiss:"))
        self.navigationItem.rightBarButtonItem = dismissButton;
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let subview = subview {
            subview.needsUpdateConstraints()
            subview.setNeedsDisplay()
        }
    }
    
    func prepare(results: (parent: Celestial, from: Celestial, to: Celestial, phaseAngle: Double, ejectionAngle: Double, ejectionSpeed: Double, deltaV: Double)) {
        self.results = results
    }
    
    func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
