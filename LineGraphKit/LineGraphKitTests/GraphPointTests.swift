//
//  GraphPointTests.swift
//  GraphKit
//
//  Created by Håkan Andersson on 28/06/15.
//  Copyright (c) 2015 Fineline. All rights reserved.
//

import UIKit
import XCTest
import LineGraphKit

class GraphPointTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func test_init_return_graphpoint() {
        let x: Double = 0
        let y: Double = 1
        let point = GraphPoint(x: x, y: y)
        
        XCTAssertEqual(point.x, x)
        XCTAssertEqual(point.y, y)
    }

    func test_init_negative_values_return_graphpoint() {
        let x: Double = -1
        let y: Double = -2
        let point = GraphPoint(x: x, y: y)
        
        XCTAssertEqual(point.x, x)
        XCTAssertEqual(point.y, y)
    }

    func test_equal_values_return_true() {
        let x: Double = 1
        let y: Double = 2
        let point = GraphPoint(x: x, y: y)
        let point2 = GraphPoint(x: x, y: y)
        
        XCTAssertEqual(point, point2)
    }
    
    func test_equal_values_not_equal_return_false() {
        let x: Double = 1
        let y: Double = 2
        let x2: Double = 2
        let y2: Double = 1

        let point = GraphPoint(x: x, y: y)
        let point2 = GraphPoint(x: x2, y: y2)
        
        XCTAssertNotEqual(point, point2)
    }
    
    func test_equal_negative_values_not_equal_return_false() {
        let x: Double = -1
        let y: Double = -2
        let x2: Double = -2
        let y2: Double = -1
        
        let point = GraphPoint(x: x, y: y)
        let point2 = GraphPoint(x: x2, y: y2)
        
        XCTAssertNotEqual(point, point2)
    }
    func test_equal_negative_decimal_values_not_equal_return_false() {
        let x: Double = -1.0001
        let y: Double = -2.0001
        let x2: Double = -2.0001
        let y2: Double = -1.0001
        
        let point = GraphPoint(x: x, y: y)
        let point2 = GraphPoint(x: x2, y: y2)
        
        XCTAssertNotEqual(point, point2)
    }
    func test_equal_decimal_values_not_equal_return_false() {
        let x: Double = 1.0001
        let y: Double = 2.0001
        let x2: Double = 1.0001
        let y2: Double = 2.0001
        
        let point = GraphPoint(x: x, y: y)
        let point2 = GraphPoint(x: x2, y: y2)
        
        XCTAssertEqual(point, point2)
    }

    func test_equal_zero_values_return_true() {
        let x: Double = 0
        let y: Double = 0
        let point = GraphPoint(x: x, y: y)
        let point2 = GraphPoint(x: x, y: y)
        
        XCTAssertEqual(point, point2)
    }
    
    func test_equal_negative_values_return_true() {
        let x: Double = -1
        let y: Double = -2
        let point = GraphPoint(x: x, y: y)
        let point2 = GraphPoint(x: x, y: y)
        
        XCTAssertEqual(point, point2)
    }
    
}
