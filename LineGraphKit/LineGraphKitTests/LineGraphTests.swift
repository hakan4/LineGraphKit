//
//  LineGraphTests.swift
//  GraphKit
//
//  Created by Håkan Andersson on 28/06/15.
//  Copyright (c) 2015 Fineline. All rights reserved.
//

import UIKit
import XCTest
@testable import LineGraphKit

class LineGraphTests: XCTestCase {

    class MockedLineGraphDataSource: LineGraphDatasource {
        fileprivate var xValues: [[Double]]!
        fileprivate var yValues: [[Double]]!
        
        init(xValues: [[Double]], yValues: [[Double]]) {
            self.xValues = xValues
            self.yValues = yValues
        }
        func lineGraph(_ lineGraph: LineGraph, animationDurationForLineWithIndex index: Int) -> Double {
            return 0
        }
        func lineGraph(_ lineGraph: LineGraph, colorForLineWithIndex index: Int) -> UIColor {
            return UIColor.red
        }
        func numberOfLines(lineGraph: LineGraph) -> Int {
            return xValues.count
        }
        func notEnoughPointsToShowMessageForLineGraph(lineGraph: LineGraph) -> String? {
            return nil
        }
        func lineGraph(lineGraph: LineGraph, minimumPointsToShowForIndex index: Int) -> Int {
            return 0
        }
        func lineGraph(_ lineGraph: LineGraph, numberOfPointsForLineWithIndex index: Int) -> Int {
            return xValues[index].count
        }
        func lineGraph(_ lineGraph: LineGraph, pointForLineWithIndex index: Int, position: Int) -> GraphPoint {
            return GraphPoint(x: xValues[index][position], y: yValues[index][position])
        }
        func lineGraph(_ lineGraph: LineGraph, titleForYValue value: Double, index: Int) -> String? {
            return nil
        }
        func lineGraph(_ lineGraph: LineGraph, titleForXValue value: Double, position: Int) -> String? {
            return nil
        }
        func fractionForSpacingInLineGraph(lineGraph: LineGraph) -> Double? {
            return nil
        }
    }
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_single_line_return_min_value() {
        let expectedMinValue = GraphPoint(x: 0, y: 1)
        let xValues: [Double] = [expectedMinValue.x, 1, 2]
        let yValues: [Double] = [expectedMinValue.y, 3, 4]
        let mockedDatasource = MockedLineGraphDataSource(xValues: [xValues], yValues: [yValues])

        let lineGraph = LineGraph()
        lineGraph.datasource = mockedDatasource

        let (minValue, _) = lineGraph.minMaxValues()
        XCTAssertEqual(minValue, expectedMinValue)
    }

    func test_single_line_negative_x_return_min_value() {
        let expectedMinValue = GraphPoint(x: -1, y: 0)
        let xValues: [Double] = [expectedMinValue.x, 1, 2]
        let yValues: [Double] = [expectedMinValue.y, 3, 4]
        let mockedDatasource = MockedLineGraphDataSource(xValues: [xValues], yValues: [yValues])
        
        let lineGraph = LineGraph()
        lineGraph.datasource = mockedDatasource
        
        let (minValue, _) = lineGraph.minMaxValues()
        XCTAssertEqual(minValue, expectedMinValue)
    }

    func test_single_line_negative_y_return_min_value() {
        let expectedMinValue = GraphPoint(x: 0, y: -1)
        let xValues: [Double] = [expectedMinValue.x, 1, 2]
        let yValues: [Double] = [expectedMinValue.y, 3, 4]
        let mockedDatasource = MockedLineGraphDataSource(xValues: [xValues], yValues: [yValues])
        
        let lineGraph = LineGraph()
        lineGraph.datasource = mockedDatasource
        
        let (minValue, _) = lineGraph.minMaxValues()
        XCTAssertEqual(minValue, expectedMinValue)
    }
    func test_single_line_negative_x_y_return_min_value() {
        let expectedMinValue = GraphPoint(x: -1, y: -1)
        let xValues: [Double] = [expectedMinValue.x, 1, 2]
        let yValues: [Double] = [expectedMinValue.y, 3, 4]
        let mockedDatasource = MockedLineGraphDataSource(xValues: [xValues], yValues: [yValues])
        
        let lineGraph = LineGraph()
        lineGraph.datasource = mockedDatasource
        
        let (minValue, _) = lineGraph.minMaxValues()
        XCTAssertEqual(minValue, expectedMinValue)
    }
    
    func test_single_line_return_max_value() {
        let expectedMaxValue = GraphPoint(x: 3, y: 5)
        let xValues: [Double] = [0, 1, expectedMaxValue.x]
        let yValues: [Double] = [3, 4, expectedMaxValue.y]
        let mockedDatasource = MockedLineGraphDataSource(xValues: [xValues], yValues: [yValues])
        
        let lineGraph = LineGraph()
        lineGraph.datasource = mockedDatasource
        
        let (_, maxValue) = lineGraph.minMaxValues()
        XCTAssertEqual(maxValue, expectedMaxValue)
    }


}
