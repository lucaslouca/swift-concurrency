//
//  FXCDrawUtil.swift
//  Fluxcapacitor
//
//  Created by Lucas Louca on 29/05/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit

class FXCDrawUtil {
    static let iconColor = UIColor.darkGrayColor()
    static let iconCGColor = iconColor.CGColor
    static let orangeColor = UIColor(red: 193.0/255.0, green: 89.0/255.0, blue: 33.0/255.0, alpha: 1.0)
    static let greenColor = UIColor(red: 134.0/255.0, green: 189.0/255.0, blue: 62.0/255.0, alpha: 1.0)
    
    /**
    Convert degrees to radians.
    
    - parameter degrees: degrees to convert to radians
    
    - returns: CGFloat number of radians orresponding to degrees
    */
    private class func degree2radian(degrees:CGFloat)->CGFloat {
        let result = CGFloat(M_PI) * degrees/180
        return result
    }
    
    /**
    Creates and returns a star path.
    
    - parameter x: origin x
    
    - parameter y: origin y
    
    - parameter radius: radius of the cycle joining the out most polygon points
    
    - parameter adjustment: degrees added to rotation of the polygon when computing the polygons points.
    
    - returns: [CGPoint] containing the points of the polygon
    */
    private class func polygonPointArray(sides:Int, x:CGFloat, y:CGFloat, radius:CGFloat, adjustment:CGFloat = 0.0)->[CGPoint] {
        let angle = degree2radian(360/CGFloat(sides))
        let cx = x
        let cy = y
        let r  = radius
        var i = sides
        var points = [CGPoint]()
        while points.count <= sides {
            let xpo = cx - r * cos(angle * CGFloat(i)+degree2radian(adjustment))
            let ypo = cy - r * sin(angle * CGFloat(i)+degree2radian(adjustment))
            points.append(CGPoint(x: xpo, y: ypo))
            i--;
        }
        return points
    }
    
    
    /**
    Creates and returns a star path.
    
    - parameter x: origin x
    
    - parameter y: origin y
    
    - parameter radius: radius of largest containable cycle in the star
    
    - parameter pointyness: constant added to the radius. radius + adjustment represents the smallest cycle that contains the star. In other words radius + adjustment  is the radius of the outer points of the star.
    
    - returns: CGPathRef representing the star
    */
    class func iconStarPath(x x:CGFloat, y:CGFloat, radius:CGFloat, sides:Int, pointyness:CGFloat) -> CGPathRef {
        let adjustment = 360/sides/2
        let path = CGPathCreateMutable()
        let points = polygonPointArray(sides, x: x, y: y, radius: radius)
        let cpg = points[0]
        let points2 = polygonPointArray(sides, x: x, y: y, radius: radius+pointyness, adjustment:CGFloat(adjustment))
        var i = 0
        CGPathMoveToPoint(path, nil, cpg.x, cpg.y)
        for p in points {
            CGPathAddLineToPoint(path, nil, points2[i].x, points2[i].y)
            CGPathAddLineToPoint(path, nil, p.x, p.y)
            i++
        }
        CGPathCloseSubpath(path)
        return path
    }
    
    /**
    Creates and returns an ItemCount icon
    
    - parameter x: top left x
    
    - parameter y: top left y
    
    - parameter scale: factor in the range of (0,1)

    - returns: CAShapeLayer representing the icon
    */
    class func iconItemCountLayer(x x:CGFloat, y:CGFloat, scale: CGFloat, color:UIColor) -> CAShapeLayer {
        let result = CAShapeLayer()
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPointMake(15.47, 7.72))
        bezierPath.addLineToPoint(CGPointMake(11.29, 0.46))
        bezierPath.addCurveToPoint(CGPointMake(10.5, 0), controlPoint1: CGPointMake(11.11, 0.15), controlPoint2: CGPointMake(10.81, 0))
        bezierPath.addCurveToPoint(CGPointMake(9.71, 0.48), controlPoint1: CGPointMake(10.19, 0), controlPoint2: CGPointMake(9.89, 0.15))
        bezierPath.addLineToPoint(CGPointMake(5.53, 7.72))
        bezierPath.addLineToPoint(CGPointMake(0.95, 7.72))
        bezierPath.addCurveToPoint(CGPointMake(0, 8.83), controlPoint1: CGPointMake(0.43, 7.72), controlPoint2: CGPointMake(0, 8.22))
        bezierPath.addCurveToPoint(CGPointMake(0.04, 9.13), controlPoint1: CGPointMake(0, 8.93), controlPoint2: CGPointMake(0.01, 9.03))
        bezierPath.addLineToPoint(CGPointMake(2.46, 19.38))
        bezierPath.addCurveToPoint(CGPointMake(4.3, 21), controlPoint1: CGPointMake(2.68, 20.31), controlPoint2: CGPointMake(3.42, 21))
        bezierPath.addLineToPoint(CGPointMake(16.7, 21))
        bezierPath.addCurveToPoint(CGPointMake(18.55, 19.38), controlPoint1: CGPointMake(17.58, 21), controlPoint2: CGPointMake(18.32, 20.31))
        bezierPath.addLineToPoint(CGPointMake(20.97, 9.13))
        bezierPath.addLineToPoint(CGPointMake(21, 8.83))
        bezierPath.addCurveToPoint(CGPointMake(20.05, 7.72), controlPoint1: CGPointMake(21, 8.22), controlPoint2: CGPointMake(20.57, 7.72))
        bezierPath.addLineToPoint(CGPointMake(15.47, 7.72))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPointMake(7.64, 7.72))
        bezierPath.addLineToPoint(CGPointMake(10.5, 2.85))
        bezierPath.addLineToPoint(CGPointMake(13.36, 7.72))
        bezierPath.addLineToPoint(CGPointMake(7.64, 7.72))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPointMake(10.5, 16.57))
        bezierPath.addCurveToPoint(CGPointMake(8.59, 14.36), controlPoint1: CGPointMake(9.45, 16.57), controlPoint2: CGPointMake(8.59, 15.58))
        bezierPath.addCurveToPoint(CGPointMake(10.5, 12.15), controlPoint1: CGPointMake(8.59, 13.14), controlPoint2: CGPointMake(9.45, 12.15))
        bezierPath.addCurveToPoint(CGPointMake(12.41, 14.36), controlPoint1: CGPointMake(11.55, 12.15), controlPoint2: CGPointMake(12.41, 13.14))
        bezierPath.addCurveToPoint(CGPointMake(10.5, 16.57), controlPoint1: CGPointMake(12.41, 15.58), controlPoint2: CGPointMake(11.55, 16.57))
        bezierPath.closePath()
        bezierPath.miterLimit = 4

        // Scale it
        bezierPath.applyTransform(CGAffineTransformMakeScale(scale, scale))
       
        // move it
        let translation = CGSizeMake(x,y)
        bezierPath.applyTransform(CGAffineTransformMakeTranslation(translation.width, translation.height))
        
        
        result.path = bezierPath.CGPath
        result.fillColor = color.CGColor
        
        return result
    }
    
    /**
    Creates and returns a price (dollar) icon
    
    - parameter x: top left x
    
    - parameter y: top left y
    
    - parameter scale: factor in the range of (0,1)
    
    - returns: CAShapeLayer representing the icon
    */
    class func iconIconPriceDollar(x x:CGFloat, y:CGFloat, scale: CGFloat, color: UIColor) -> CAShapeLayer {
        let result = CAShapeLayer()
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPointMake(9.45, 13.81))
        bezierPath.addLineToPoint(CGPointMake(11.55, 13.81))
        bezierPath.addLineToPoint(CGPointMake(11.55, 12.75))
        bezierPath.addLineToPoint(CGPointMake(12.6, 12.75))
        bezierPath.addCurveToPoint(CGPointMake(13.65, 11.69), controlPoint1: CGPointMake(13.18, 12.75), controlPoint2: CGPointMake(13.65, 12.27))
        bezierPath.addLineToPoint(CGPointMake(13.65, 8.5))
        bezierPath.addCurveToPoint(CGPointMake(12.6, 7.44), controlPoint1: CGPointMake(13.65, 7.92), controlPoint2: CGPointMake(13.18, 7.44))
        bezierPath.addLineToPoint(CGPointMake(9.45, 7.44))
        bezierPath.addLineToPoint(CGPointMake(9.45, 6.37))
        bezierPath.addLineToPoint(CGPointMake(13.65, 6.37))
        bezierPath.addLineToPoint(CGPointMake(13.65, 4.25))
        bezierPath.addLineToPoint(CGPointMake(11.55, 4.25))
        bezierPath.addLineToPoint(CGPointMake(11.55, 3.19))
        bezierPath.addLineToPoint(CGPointMake(9.45, 3.19))
        bezierPath.addLineToPoint(CGPointMake(9.45, 4.25))
        bezierPath.addLineToPoint(CGPointMake(8.4, 4.25))
        bezierPath.addCurveToPoint(CGPointMake(7.35, 5.31), controlPoint1: CGPointMake(7.82, 4.25), controlPoint2: CGPointMake(7.35, 4.73))
        bezierPath.addLineToPoint(CGPointMake(7.35, 8.5))
        bezierPath.addCurveToPoint(CGPointMake(8.4, 9.56), controlPoint1: CGPointMake(7.35, 9.08), controlPoint2: CGPointMake(7.82, 9.56))
        bezierPath.addLineToPoint(CGPointMake(11.55, 9.56))
        bezierPath.addLineToPoint(CGPointMake(11.55, 10.62))
        bezierPath.addLineToPoint(CGPointMake(7.35, 10.62))
        bezierPath.addLineToPoint(CGPointMake(7.35, 12.75))
        bezierPath.addLineToPoint(CGPointMake(9.45, 12.75))
        bezierPath.addLineToPoint(CGPointMake(9.45, 13.81))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPointMake(18.9, 0))
        bezierPath.addLineToPoint(CGPointMake(2.1, 0))
        bezierPath.addCurveToPoint(CGPointMake(0.01, 2.12), controlPoint1: CGPointMake(0.93, 0), controlPoint2: CGPointMake(0.01, 0.95))
        bezierPath.addLineToPoint(CGPointMake(0, 14.88))
        bezierPath.addCurveToPoint(CGPointMake(2.1, 17), controlPoint1: CGPointMake(0, 16.05), controlPoint2: CGPointMake(0.93, 17))
        bezierPath.addLineToPoint(CGPointMake(18.9, 17))
        bezierPath.addCurveToPoint(CGPointMake(21, 14.88), controlPoint1: CGPointMake(20.07, 17), controlPoint2: CGPointMake(21, 16.05))
        bezierPath.addLineToPoint(CGPointMake(21, 2.12))
        bezierPath.addCurveToPoint(CGPointMake(18.9, 0), controlPoint1: CGPointMake(21, 0.95), controlPoint2: CGPointMake(20.07, 0))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPointMake(18.9, 14.88))
        bezierPath.addLineToPoint(CGPointMake(2.1, 14.88))
        bezierPath.addLineToPoint(CGPointMake(2.1, 2.12))
        bezierPath.addLineToPoint(CGPointMake(18.9, 2.12))
        bezierPath.addLineToPoint(CGPointMake(18.9, 14.88))
        bezierPath.closePath()
        bezierPath.miterLimit = 4;
        
        // Scale it
        bezierPath.applyTransform(CGAffineTransformMakeScale(scale, scale))
        
        // move it
        let translation = CGSizeMake(x,y)
        bezierPath.applyTransform(CGAffineTransformMakeTranslation(translation.width, translation.height))
        
        result.path = bezierPath.CGPath
        result.fillColor = color.CGColor
        
        return result
    }
    
    /**
    Creates and returns an Time icon
    
    - parameter x: top left x
    
    - parameter y: top left y
    
    - parameter scale: factor in the range of (0,1)
    
    - returns: CAShapeLayer representing the icon
    */
    class func iconTimeLayer(x x:CGFloat, y:CGFloat, scale: CGFloat, color: UIColor) -> CAShapeLayer {
        let result = CAShapeLayer()

        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPointMake(10.49, 0))
        bezierPath.addCurveToPoint(CGPointMake(0, 10.5), controlPoint1: CGPointMake(4.69, 0), controlPoint2: CGPointMake(0, 4.7))
        bezierPath.addCurveToPoint(CGPointMake(10.49, 21), controlPoint1: CGPointMake(0, 16.3), controlPoint2: CGPointMake(4.69, 21))
        bezierPath.addCurveToPoint(CGPointMake(21, 10.5), controlPoint1: CGPointMake(16.3, 21), controlPoint2: CGPointMake(21, 16.3))
        bezierPath.addCurveToPoint(CGPointMake(10.49, 0), controlPoint1: CGPointMake(21, 4.7), controlPoint2: CGPointMake(16.3, 0))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPointMake(10.5, 18.9))
        bezierPath.addCurveToPoint(CGPointMake(2.1, 10.5), controlPoint1: CGPointMake(5.86, 18.9), controlPoint2: CGPointMake(2.1, 15.14))
        bezierPath.addCurveToPoint(CGPointMake(10.5, 2.1), controlPoint1: CGPointMake(2.1, 5.86), controlPoint2: CGPointMake(5.86, 2.1))
        bezierPath.addCurveToPoint(CGPointMake(18.9, 10.5), controlPoint1: CGPointMake(15.14, 2.1), controlPoint2: CGPointMake(18.9, 5.86))
        bezierPath.addCurveToPoint(CGPointMake(10.5, 18.9), controlPoint1: CGPointMake(18.9, 15.14), controlPoint2: CGPointMake(15.14, 18.9))
        bezierPath.closePath()
        bezierPath.miterLimit = 4;

        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.moveToPoint(CGPointMake(10.5, 4))
        bezier2Path.addLineToPoint(CGPointMake(8.67, 4))
        bezier2Path.addLineToPoint(CGPointMake(8.67, 11.21))
        bezier2Path.addLineToPoint(CGPointMake(15.08, 15))
        bezier2Path.addLineToPoint(CGPointMake(16, 13.52))
        bezier2Path.addLineToPoint(CGPointMake(10.5, 10.31))
        bezier2Path.addLineToPoint(CGPointMake(10.5, 4))
        bezier2Path.closePath()
        bezier2Path.miterLimit = 4;

        
        // Scale it
        bezierPath.applyTransform(CGAffineTransformMakeScale(scale, scale))
        bezier2Path.applyTransform(CGAffineTransformMakeScale(scale, scale))
        
        // move it
        let translation = CGSizeMake(x,y)
        bezierPath.applyTransform(CGAffineTransformMakeTranslation(translation.width, translation.height))
        bezier2Path.applyTransform(CGAffineTransformMakeTranslation(translation.width, translation.height))
        
        let cycle = CAShapeLayer()
        cycle.path = bezierPath.CGPath
        cycle.fillColor = color.CGColor
        
        let hand = CAShapeLayer()
        hand.path = bezier2Path.CGPath
        hand.fillColor = color.CGColor
        
        result.addSublayer(cycle)
        result.addSublayer(hand)

        return result
    }
    
    /**
    Creates and returns an Radius icon
    
    - parameter x: top left x
    
    - parameter y: top left y
    
    - parameter scale: factor in the range of (0,1)
    
    - returns: CAShapeLayer representing the icon
    */
    class func iconLocationLayer(x x:CGFloat, y:CGFloat, scale: CGFloat, color:UIColor) -> CAShapeLayer {
        let result = CAShapeLayer()

        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPointMake(10.5, -0))
        bezierPath.addCurveToPoint(CGPointMake(0, 9.8), controlPoint1: CGPointMake(4.7, -0), controlPoint2: CGPointMake(0, 4.38))
        bezierPath.addCurveToPoint(CGPointMake(10.5, 28), controlPoint1: CGPointMake(0, 17.15), controlPoint2: CGPointMake(10.5, 28))
        bezierPath.addCurveToPoint(CGPointMake(21, 9.8), controlPoint1: CGPointMake(10.5, 28), controlPoint2: CGPointMake(21, 17.15))
        bezierPath.addCurveToPoint(CGPointMake(10.5, -0), controlPoint1: CGPointMake(21, 4.38), controlPoint2: CGPointMake(16.3, -0))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPointMake(10.5, 13.3))
        bezierPath.addCurveToPoint(CGPointMake(6.75, 9.8), controlPoint1: CGPointMake(8.43, 13.3), controlPoint2: CGPointMake(6.75, 11.73))
        bezierPath.addCurveToPoint(CGPointMake(10.5, 6.3), controlPoint1: CGPointMake(6.75, 7.87), controlPoint2: CGPointMake(8.43, 6.3))
        bezierPath.addCurveToPoint(CGPointMake(14.25, 9.8), controlPoint1: CGPointMake(12.57, 6.3), controlPoint2: CGPointMake(14.25, 7.87))
        bezierPath.addCurveToPoint(CGPointMake(10.5, 13.3), controlPoint1: CGPointMake(14.25, 11.73), controlPoint2: CGPointMake(12.57, 13.3))
        bezierPath.closePath()
        bezierPath.miterLimit = 4;
        
        // Scale it
        bezierPath.applyTransform(CGAffineTransformMakeScale(scale, scale))
        
        // move it
        let translation = CGSizeMake(x,y)
        bezierPath.applyTransform(CGAffineTransformMakeTranslation(translation.width, translation.height))
        
        
        result.path = bezierPath.CGPath
        result.fillColor = color.CGColor
        
        return result
    }

}
