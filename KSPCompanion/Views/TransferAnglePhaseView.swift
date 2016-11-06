//
//  InterorbitalView.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 05/06/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import Darwin
import UIKit

@IBDesignable class TransferAnglePhaseView: UIView {
    let π = CGFloat(M_PI)
    
    @IBInspectable var parentColor: UIColor = UIColor.yellow
    @IBInspectable var parentSize: CGFloat = 20
    
    @IBInspectable var fromSemiMajorAxis: CGFloat = 10
    @IBInspectable var fromColor: UIColor = UIColor.blue
    @IBInspectable var fromSize: CGFloat = 10
    
    @IBInspectable var toSemiMajorAxis: CGFloat = 15
    @IBInspectable var toColor: UIColor = UIColor.orange
    @IBInspectable var toSize: CGFloat = 10
    
    @IBInspectable var calculatedAnglePhase: CGFloat = 0
    var vesselTrajectory: Orbit?
    
    var fromIsInterior: Bool {
        return fromSemiMajorAxis < toSemiMajorAxis
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x:bounds.width/2, y: bounds.height/2)
        
        // Detecting outside and inside planet
        var outMajorAxis: CGFloat = 1, inMajorAxis: CGFloat = 1, outSize: CGFloat = 1, inSize: CGFloat = 1

        if fromIsInterior {
            outMajorAxis =  toSemiMajorAxis
            outSize = toSize
            inMajorAxis = fromSemiMajorAxis
            inSize = fromSize
        } else {
            outMajorAxis = fromSemiMajorAxis
            outSize = fromSize
            inMajorAxis = toSemiMajorAxis
            inSize = toSize
        }
        
        // Calculating radiuses
        let outRadius = min(bounds.width, bounds.height)/2 - outSize/2 - 3
        let inRadius = inMajorAxis/outMajorAxis * outRadius + parentSize/2 + inSize
        
        // Calculating planets position
        let fromPosition = CGPoint(x: (fromIsInterior ? inRadius: outRadius) + center.x, y: center.y)
        let toPosition = CGPoint(
            x: (fromIsInterior ? outRadius: inRadius) * cos(2*π*calculatedAnglePhase/360) + center.x,
            y: (fromIsInterior ? outRadius: inRadius) * sin(-2*π*calculatedAnglePhase/360) + center.y)
        let endPosition = CGPoint(
            x: -(fromIsInterior ? outRadius: inRadius) + center.x,
            y: center.y)
        
        // Drawing orbits
        let outPath = UIBezierPath(arcCenter: center, radius: outRadius, startAngle: 0, endAngle: 2*π, clockwise: true)
        let inPath = UIBezierPath(arcCenter: center, radius: inRadius, startAngle: 0, endAngle: 2*π, clockwise: true)
        
        UIColor.gray.setStroke()
        outPath.stroke()
        inPath.stroke()
        
        // Drawing angle lines
        let angleLines = UIBezierPath()
        angleLines.move(to: center)
        angleLines.addLine(to: fromPosition)
        angleLines.move(to: center)
        angleLines.addLine(to: toPosition)
        angleLines.stroke()
        
        // Drawing vessel trajectory
        let theCGContext = UIGraphicsGetCurrentContext()
        theCGContext?.saveGState()
        
        let vesselOrbit = Orbit(apoapsis: Double(outRadius), periapsis: Double(inRadius))
        let trajectoryRect = CGRect(x: center.x - (fromIsInterior ? outRadius : inRadius), y: center.y - CGFloat(vesselOrbit.b), width: CGFloat(vesselOrbit.a*2), height: CGFloat(vesselOrbit.b*2))
        
        let clip = UIBezierPath(rect: CGRect(x: 0, y: 0, width: center.x*2, height: center.y))
        clip.addClip()
        let vesselTrajectory = UIBezierPath(ovalIn: trajectoryRect)
        UIColor.orange.setStroke()
        vesselTrajectory.stroke()
        
        theCGContext?.restoreGState()
        
        
        // Drawing angle
        let angle = UIBezierPath(arcCenter: center, radius: (inRadius-parentSize/2)/3 + parentSize/2, startAngle: 0, endAngle: -2*π*calculatedAnglePhase/360, clockwise: calculatedAnglePhase<0)
        UIColor.red.setStroke()
        angle.stroke()
        
        let textRadius = (inRadius-parentSize/2)/3 + parentSize/2 + 20
        let textAngle = -π*calculatedAnglePhase/360
        "\(round(calculatedAnglePhase*100)/100)°".drawAtPoint(
            CGPoint(x: center.x + textRadius*cos(textAngle) - 10, y: center.y + textRadius*sin(textAngle) - 6),
            withAttributes: [NSForegroundColorAttributeName: UIColor.red])
        
        // Drawing the parent of the orbits
        let parentPath = UIBezierPath(arcCenter: center, radius: parentSize/2, startAngle: 0, endAngle: 2*π, clockwise: true)
        parentColor.setFill()
        parentPath.fill()
        
        // Drawing the from planet
        let fromRect = CGRect(x: fromPosition.x - fromSize/2, y: fromPosition.y - fromSize/2, width: fromSize, height: fromSize)
        let fromPath = UIBezierPath(ovalIn: fromRect)
        fromColor.setFill()
        fromPath.fill()
        
        // Drawing the destination planet
        let toRect = CGRect(x: toPosition.x - toSize/2, y: toPosition.y - toSize/2, width: toSize, height: toSize)
        let toPath = UIBezierPath(ovalIn: toRect)
        toColor.setFill()
        toPath.fill()
        
        // Drawing the end planet
        let endRect = CGRect(x: endPosition.x - toSize/2, y: endPosition.y - toSize/2, width: toSize, height: toSize)
        let endPath = UIBezierPath(ovalIn: endRect)
        toColor.setStroke()
        endPath.stroke()
    }
}

extension String {
    func drawAtPoint(_ point: CGPoint, withAttributes: [String : AnyObject]?) {
        (self as NSString).draw(at: point, withAttributes: withAttributes)
    }
}
