//
//  LineLayer.swift
//  GraphKit
//
//  Created by Håkan Andersson on 27/06/15.
//  Copyright (c) 2015 Fineline. All rights reserved.
//

import UIKit

class LineLayer: CAShapeLayer {
    
    final var animationDuration: Double! = 1
    fileprivate final var points: [Point]!
    
    init(points: [Point]) {
        super.init()
        fillColor = UIColor.clear.cgColor
        self.points = points
        self.path = createPath()
        contentsScale = UIScreen.main.scale
        setNeedsDisplay()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        if let sliceLayer = layer as? LineLayer {
            self.animationDuration = sliceLayer.animationDuration
            self.points = sliceLayer.points
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func action(forKey event: String) -> CAAction? {
        if event == "strokeEnd" {
            return makeAnimationForKey(event)
        }
        return super.action(forKey: event)
    }
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == "strokeEnd" {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    fileprivate func createPath() -> CGPath {
        let path = CGMutablePath()
        
        var mutablePoints = points
        mutablePoints?.remove(at: 0)
        if var mutablePoints = mutablePoints {
            let initialPoint = mutablePoints.remove(at: 0)
            path.move(to: CGPoint(x: initialPoint.x, y: initialPoint.y))
            for point in mutablePoints {
                path.addLine(to: CGPoint(x: point.x, y: point.y))
            }
        }
        return path
    }
    
    fileprivate func makeAnimationForKey(_ key: String) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: key)
        animation.fromValue = self.presentation()?.value(forKeyPath: key)
        animation.toValue = self.value(forKeyPath: key)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.duration = animationDuration
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        return animation
    }
    
    func drawLine() {
        strokeEnd = 0.0
    }
    func removeLine() {
        strokeEnd = 1.0
    }
    
}
