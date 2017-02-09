//
//  LineGraphViewController.swift
//  GraphKitDemo
//
//  Created by Håkan Andersson on 20/06/15.
//  Copyright (c) 2015 Fineline. All rights reserved.
//

import UIKit
import LineGraphKit

class LineGraphViewController: UIViewController, LineGraphDatasource {

    @IBOutlet fileprivate weak var lineGraph: LineGraph!
    
    fileprivate var graphLine: [[Double]]!
    fileprivate var yearLine: [[Double]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lineGraph.datasource = self
        graphLine = [[1]]//[[1,5,6,2,4,3,8,4,3,2,5,7,8], Array([1,5,6,2,4,3,8,4,3,2,5,7,8].reverse()), [14,3,12,5,7,18], [6,2,3,5,2,7], [1,10,1]]
        yearLine = [[2000]]//[[2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013], [2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013], [2005,2006,2007,2008,2009,2010], [2009,2010,2011,2012,2013,2014],[2000,2010,2011]]
        
/*        graphLine = [[1,2,1,2,1,2,1,2]]
        yearLine = [[2000,2001,2002,2003,2004,2005,2006,2007]]*/
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        lineGraph.drawGraph()
    }
    
    func numberOfLines(lineGraph: LineGraph) -> Int {
        return graphLine.count
    }
    
    func notEnoughPointsToShowMessageForLineGraph(lineGraph: LineGraph) -> String? {
        return "Not enough points to show graph, this is a slightly longer text for testing"
    }
    
    func lineGraph(lineGraph: LineGraph, minimumPointsToShowForIndex index: Int) -> Int {
        return 1
    }
    
    func lineGraph(lineGraph: LineGraph, numberOfPointsForLineWithIndex index: Int) -> Int {
        return graphLine[index].count
    }

    
    func lineGraph(lineGraph: LineGraph, pointForLineWithIndex index: Int, position: Int) -> GraphPoint {
        return GraphPoint(x: yearLine[index][position], y: graphLine[index][position])
    }
    
    func lineGraph(lineGraph: LineGraph, animationDurationForLineWithIndex index: Int) -> Double {
        return 3
    }
    
    func lineGraph(lineGraph: LineGraph, colorForLineWithIndex index: Int) -> UIColor {
        return UIColor.randomColor()
    }

    func lineGraph(lineGraph: LineGraph, titleForXValue value: Double, position: Int) -> String? {
        print("X for value: \(value) - position: \(position)")
        return "x\(value)"
    }
    
    func lineGraph(lineGraph: LineGraph, titleForYValue value: Double, index: Int) -> String? {
        print("Y for value: \(value) - index: \(index)")
        return "y\(value)"
    }
    func fractionForSpacingInLineGraph(lineGraph: LineGraph) -> Double? {
        return 0.8
    }
}
