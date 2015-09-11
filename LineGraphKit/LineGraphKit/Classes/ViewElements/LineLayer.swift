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
    private final var points: [Point]!
    
    init(points: [Point]) {
        super.init()
        fillColor = UIColor.clearColor().CGColor
        self.points = points
        self.path = createPath()
        contentsScale = UIScreen.mainScreen().scale
        setNeedsDisplay()
    }
    
    override init(layer: AnyObject) {
        super.init(layer: layer)
        if let sliceLayer = layer as? LineLayer {
            self.animationDuration = sliceLayer.animationDuration
            self.points = sliceLayer.points
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func actionForKey(event: String) -> CAAction? {
        if event == "strokeEnd" {
            return makeAnimationForKey(event)
        }
        return super.actionForKey(event)
    }
    
    override class func needsDisplayForKey(key: String) -> Bool {
        if key == "strokeEnd" {
            return true
        }
        return super.needsDisplayForKey(key)
    }
    
    private func createPath() -> CGPathRef {
        let path = CGPathCreateMutable()
        
        var mutablePoints = points
        let initialPoint = mutablePoints.removeAtIndex(0)
        CGPathMoveToPoint(path, nil, initialPoint.x, initialPoint.y)
        for point in mutablePoints {
            CGPathAddLineToPoint(path, nil, point.x, point.y)
        }
        return path
    }
    
    private func makeAnimationForKey(key: String) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: key)
        animation.fromValue = self.presentationLayer()?.valueForKeyPath(key)
        animation.toValue = self.valueForKeyPath(key)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.duration = animationDuration
        animation.removedOnCompletion = false
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
