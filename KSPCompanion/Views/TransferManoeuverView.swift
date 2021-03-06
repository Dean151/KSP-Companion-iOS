//
//  TransferManoeuverView.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 09/06/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import Darwin
import UIKit

@IBDesignable class TransferManoeuverView: UIView {
    let π = CGFloat(M_PI)
    
    @IBInspectable var fromName: String = "Test"
    @IBInspectable var fromColor: UIColor = UIColor.blue
    
    @IBInspectable var angle: CGFloat = 90
    @IBInspectable var toPrograde: Bool = true
    
    @IBInspectable var deltaV: Double = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x:bounds.width/2, y: bounds.height/2)
        let size = min(bounds.width, bounds.height)
        
        let fromSize: CGFloat = size/8
        let fromOrbitSize: CGFloat = size*5
        
        let orbitSize: CGFloat = size/4
        let angleSize: CGFloat = size/6
        
        // Parking orbit
        let orbitPath = UIBezierPath(arcCenter: center, radius: orbitSize, startAngle: 0, endAngle: 2*π, clockwise: true)
        UIColor.gray.setStroke()
        orbitPath.stroke()
        
        // Celestial orbit
        let fromOrbitPath = UIBezierPath(arcCenter: CGPoint(x: center.x - fromOrbitSize, y: center.y), radius: fromOrbitSize, startAngle: -π/4, endAngle: π/4, clockwise: true)
        fromOrbitPath.lineWidth = 2
        fromColor.setStroke()
        fromOrbitPath.stroke()
        
        // angle lines draw
        let fromAngle: CGFloat = toPrograde ? -90 : 90
        let toAngle: CGFloat = fromAngle + angle
        
        let fromPosition = CGPoint( x: center.x, y: (toPrograde ? 0 : bounds.height))
        let toPosition = CGPoint( x: center.x + size * cos( toAngle * 2 * π / 360 ), y: center.y + size * sin( toAngle * 2 * π / 360 ) )
        
        let angleLines = UIBezierPath()
        angleLines.move(to: center)
        angleLines.addLine(to: fromPosition)
        angleLines.move(to: center)
        angleLines.addLine(to: toPosition)
        angleLines.lineWidth = 2
        UIColor.red.setStroke()
        angleLines.stroke()
        
        // Reference Label
        let refText = "\(fromName) " + (toPrograde ? "Prograde" : "Retrograde")
        refText.draw(at: CGPoint( x: center.x + 10, y: fromPosition.y + (toPrograde ? 1 : -1) * 20 ), withAttributes: [NSForegroundColorAttributeName: fromColor])
        
        // Angle Curve
        let angleCurve = UIBezierPath(arcCenter: center, radius: angleSize, startAngle: fromAngle * 2 * π / 360, endAngle: toAngle * 2 * π / 360, clockwise: true)
        UIColor.red.setStroke()
        angleCurve.stroke()
        
        let textRadius = angleSize + 20
        let textAngle = π * ( toAngle + fromAngle ) / 360
        "\(round(angle*100)/100)°".draw(
            at: CGPoint(x: center.x + textRadius*cos(textAngle) - 10, y: center.y + textRadius*sin(textAngle) - 6),
            withAttributes: [NSForegroundColorAttributeName: UIColor.red])
        
        // Celestial shape
        var fromPath = UIBezierPath(arcCenter: center, radius: fromSize, startAngle: π/2, endAngle: 3*π/2, clockwise: true)
        fromColor.setFill()
        fromPath.fill()
        fromPath =  UIBezierPath(arcCenter: center, radius: fromSize, startAngle: π/2, endAngle: 3*π/2, clockwise: false)
        fromColor.darkerColor().setFill()
        fromPath.fill()
        
        // Vessel triangle
        let vesselPosition = CGPoint(
            x: center.x + orbitSize * cos(2 * π * toAngle / 360),
            y: center.y + orbitSize * sin(2 * π * toAngle / 360)
        )
        
        let vessel = UIBezierPath(equilateralTriangleWithSize: 20, center: vesselPosition)
        UIColor.white.setFill()
        vessel.fill()
        
        // Manoeuver informations
        let mInfo = "∆v= \(round(deltaV*10)/10) m/s"
        mInfo.draw(at: CGPoint(x: vesselPosition.x - 35, y: vesselPosition.y + 10), withAttributes: [NSForegroundColorAttributeName: UIColor.white])
    }
}

extension UIBezierPath {
    convenience init(equilateralTriangleWithSize: CGFloat, center: CGPoint) {
        self.init()
        
        let altitude = CGFloat(sqrt(3.0) / 2.0 * equilateralTriangleWithSize)
        let heightToCenter = altitude / 3
        
        move(to: CGPoint(x:center.x, y:center.y - heightToCenter*2))
        addLine(to: CGPoint(x:center.x + equilateralTriangleWithSize/2, y:center.y + heightToCenter))
        addLine(to: CGPoint(x:center.x - equilateralTriangleWithSize/2, y:center.y + heightToCenter))
        close()
    }
}

extension UIColor {
    func darkerColor() -> UIColor {
        let cst:CGFloat = 0.3
        var r:CGFloat = 0, g:CGFloat = 0, b:CGFloat = 0, a:CGFloat = 0
        
        if self.getRed(&r, green: &g, blue: &b, alpha: &a){
            return UIColor(red: max(r - cst, 0.0), green: max(g - cst, 0.0), blue: max(b - cst, 0.0), alpha: a)
        }
        
        return UIColor()
    }
}
