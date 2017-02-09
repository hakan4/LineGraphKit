//
//  GraphPoint.swift
//  GraphKit
//
//  Created by Håkan Andersson on 27/06/15.
//  Copyright (c) 2015 Fineline. All rights reserved.
//

import Foundation

open class GraphPoint: CustomStringConvertible, Equatable {
    final public var x: Double = 0.0
    final public var y: Double = 0.0
    
    open var description: String {
        return "{x: \(x), y: \(y)}"
    }
    
    public init() {
    }
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    class func yStepCalculation(_ maxValue: GraphPoint, minValue: GraphPoint, count: Int, i: Int) -> Double {
        return minValue.y + ((Double(count - i - 1) * (maxValue.y - minValue.y)) / Double(count - 1))
    }
    
}
public func ==(lhs: GraphPoint, rhs: GraphPoint) -> Bool {
    return lhs.x == rhs.x && lhs.y == lhs.y
}
