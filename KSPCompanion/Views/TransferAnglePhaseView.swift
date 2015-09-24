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
    
    @IBInspectable var parentColor: UIColor = UIColor.yellowColor()
    @IBInspectable var parentSize: CGFloat = 20
    
    @IBInspectable var fromSemiMajorAxis: CGFloat = 10
    @IBInspectable var fromColor: UIColor = UIColor.blueColor()
    @IBInspectable var fromSize: CGFloat = 10
    
    @IBInspectable var toSemiMajorAxis: CGFloat = 15
    @IBInspectable var toColor: UIColor = UIColor.orangeColor()
    @IBInspectable var toSize: CGFloat = 10
    
    @IBInspectable var calculatedAnglePhase: CGFloat = 0
    var vesselTrajectory: Orbit?
    
    var fromIsInterior: Bool {
        return fromSemiMajorAxis < toSemiMajorAxis
    }
    
    override func drawRect(rect: CGRect) {
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
        
        UIColor.grayColor().setStroke()
        outPath.stroke()
        inPath.stroke()
        
        // Drawing angle lines
        let angleLines = UIBezierPath()
        angleLines.moveToPoint(center)
        angleLines.addLineToPoint(fromPosition)
        angleLines.moveToPoint(center)
        angleLines.addLineToPoint(toPosition)
        angleLines.stroke()
        
        // Drawing vessel trajectory
        let theCGContext = UIGraphicsGetCurrentContext()
        CGContextSaveGState(theCGContext)
        
        let vesselOrbit = Orbit(apoapsis: Double(outRadius), periapsis: Double(inRadius))
        let trajectoryRect = CGRectMake(center.x - (fromIsInterior ? outRadius : inRadius), center.y - CGFloat(vesselOrbit.b), CGFloat(vesselOrbit.a*2), CGFloat(vesselOrbit.b*2))
        
        let clip = UIBezierPath(rect: CGRectMake(0, 0, center.x*2, center.y))
        clip.addClip()
        let vesselTrajectory = UIBezierPath(ovalInRect: trajectoryRect)
        UIColor.orangeColor().setStroke()
        vesselTrajectory.stroke()
        
        CGContextRestoreGState(theCGContext)
        
        
        // Drawing angle
        let angle = UIBezierPath(arcCenter: center, radius: (inRadius-parentSize/2)/3 + parentSize/2, startAngle: 0, endAngle: -2*π*calculatedAnglePhase/360, clockwise: calculatedAnglePhase<0)
        UIColor.redColor().setStroke()
        angle.stroke()
        
        let textRadius = (inRadius-parentSize/2)/3 + parentSize/2 + 20
        let textAngle = -π*calculatedAnglePhase/360
        "\(round(calculatedAnglePhase*100)/100)°".drawAtPoint(
            CGPoint(x: center.x + textRadius*cos(textAngle) - 10, y: center.y + textRadius*sin(textAngle) - 6),
            withAttributes: [NSForegroundColorAttributeName: UIColor.redColor()])
        
        // Drawing the parent of the orbits
        let parentPath = UIBezierPath(arcCenter: center, radius: parentSize/2, startAngle: 0, endAngle: 2*π, clockwise: true)
        parentColor.setFill()
        parentPath.fill()
        
        // Drawing the from planet
        let fromRect = CGRect(x: fromPosition.x - fromSize/2, y: fromPosition.y - fromSize/2, width: fromSize, height: fromSize)
        let fromPath = UIBezierPath(ovalInRect: fromRect)
        fromColor.setFill()
        fromPath.fill()
        
        // Drawing the destination planet
        let toRect = CGRect(x: toPosition.x - toSize/2, y: toPosition.y - toSize/2, width: toSize, height: toSize)
        let toPath = UIBezierPath(ovalInRect: toRect)
        toColor.setFill()
        toPath.fill()
        
        // Drawing the end planet
        let endRect = CGRect(x: endPosition.x - toSize/2, y: endPosition.y - toSize/2, width: toSize, height: toSize)
        let endPath = UIBezierPath(ovalInRect: endRect)
        toColor.setStroke()
        endPath.stroke()
    }
}

extension String {
    func drawAtPoint(point: CGPoint, withAttributes: [String : AnyObject]?) {
        (self as NSString).drawAtPoint(point, withAttributes: withAttributes)
    }
}