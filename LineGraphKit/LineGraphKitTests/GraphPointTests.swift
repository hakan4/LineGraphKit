//
//  GraphPointTests.swift
//  GraphKit
//
//  Created by Håkan Andersson on 28/06/15.
//  Copyright (c) 2015 Fineline. All rights reserved.
//

import UIKit
import XCTest
@testable import LineGraphKit

class GraphPointTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func test_description_format_return_description() {
        let x: Double = 0
        let y: Double = 1
        let point = GraphPoint(x: x, y: y)
        
        let expectedResult = "{x: \(x), y: \(y)}"
        
        XCTAssertEqual(point.description, expectedResult)
    }
    
    func test_init_return_graphpoint_default_zero_values() {
        let expectedDefaultValue: Double = 0
        let point = GraphPoint()
        
        XCTAssertEqual(point.x, expectedDefaultValue)
        XCTAssertEqual(point.y, expectedDefaultValue)
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
    
    func test_y_step_caluclation_first_value_return_max_y() {
        let minX: Double = 0
        let minY: Double = 1
        let maxX: Double = 0
        let maxY: Double = 5

        let count: Int = 2
        let index: Int = 0

        
        let minValue = GraphPoint(x: minX, y: minY)
        let maxValue = GraphPoint(x: maxX, y: maxY)
        
        let value = GraphPoint.yStepCalculation(maxValue, minValue: minValue, count: count, i: index)
        XCTAssertEqual(value, maxY)
    }
    func test_y_step_caluclation_last_value_return_min_y() {
        let minX: Double = 0
        let minY: Double = 1
        let maxX: Double = 0
        let maxY: Double = 5
        
        let count: Int = 2
        let index: Int = 1
        
        let minValue = GraphPoint(x: minX, y: minY)
        let maxValue = GraphPoint(x: maxX, y: maxY)
        
        let value = GraphPoint.yStepCalculation(maxValue, minValue: minValue, count: count, i: index)
        XCTAssertEqual(value, minY)
    }
    
    func test_y_step_caluclation_middle_value_count_3_return_middle_value() {
        let minX: Double = 0
        let minY: Double = 1
        let maxX: Double = 0
        let maxY: Double = 5
        
        let count: Int = 3
        let index: Int = 1
        let expectedValue: Double = (maxY - minY) / 2.0 + minY
        
        let minValue = GraphPoint(x: minX, y: minY)
        let maxValue = GraphPoint(x: maxX, y: maxY)
        
        let value = GraphPoint.yStepCalculation(maxValue, minValue: minValue, count: count, i: index)
        XCTAssertEqual(value, expectedValue)
    }
    
}
