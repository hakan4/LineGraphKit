//
//  PlotLayer.swift
//  GraphKit
//
//  Created by Håkan Andersson on 27/06/15.
//  Copyright (c) 2015 Fineline. All rights reserved.
//

import UIKit

class PlotLayer: CALayer {
    
    
    private var leftBorderLayer: BorderLayer!
    private var bottomBorderLayer: BorderLayer!
    
    override init() {
        super.init()
        leftBorderLayer = BorderLayer()
        bottomBorderLayer = BorderLayer()
        addSublayer(bottomBorderLayer)
        addSublayer(leftBorderLayer)
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        leftBorderLayer.frame = CGRect(x: 0, y: 0, width: 0.5, height: self.frame.size.height)
        bottomBorderLayer.frame = CGRect(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(layer: AnyObject) {
        super.init(layer: layer)
        if let _ = layer as? PlotLayer {
            
        }
    }
    
    func addLineLayer(lineLayer: LineLayer) {
        lineLayer.frame = bounds
        addSublayer(lineLayer)
    }
    
    func clearLineLayers() {
        if let subs = sublayers {
            for layer in subs {
                if let sublayer = layer as? LineLayer {
                    sublayer.removeFromSuperlayer()
                }
            }
        }
    }
}

class BorderLayer: CALayer {
    override init() {
        super.init()
        backgroundColor = UIColor.lightGrayColor().CGColor
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
