//
//  TransferResultModalController.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 09/06/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import UIKit

class TransferResultModalController: UIViewController {
    
    weak var subview: UIView?
    var results: (parent: Celestial, from: Celestial, to: Celestial, phaseAngle: Double, ejectionAngle: Double, ejectionSpeed: Double, deltaV: Double)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        
        let dismissButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(TransferResultModalController.dismiss(_:)))
        self.navigationItem.rightBarButtonItem = dismissButton;
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let subview = subview {
            subview.needsUpdateConstraints()
            subview.setNeedsDisplay()
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        guard let subview = subview else { return }
        
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: subview, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: subview, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: subview, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: subview, attribute: .bottom, multiplier: 1, constant: 0))
    }
    
    func prepare(_ results: (parent: Celestial, from: Celestial, to: Celestial, phaseAngle: Double, ejectionAngle: Double, ejectionSpeed: Double, deltaV: Double)) {
        self.results = results
    }
    
    func dismiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
