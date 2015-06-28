//
//  PlotLayer.swift
//  GraphKit
//
//  Created by Håkan Andersson on 27/06/15.
//  Copyright (c) 2015 Fineline. All rights reserved.
//

import UIKit

class PlotLayer: CALayer {
    
    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addLineLayer(lineLayer: LineLayer) {
        lineLayer.frame = bounds
        addSublayer(lineLayer)
    }
    
    func clearLineLayers() {
        if let subs = sublayers as? [CALayer] {
            for layer in sublayers {
                if let sublayer = layer as? LineLayer {
                    sublayer.removeFromSuperlayer()
                }
            }
        }
    }
}
