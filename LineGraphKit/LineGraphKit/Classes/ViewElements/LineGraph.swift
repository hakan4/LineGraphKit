//
//  LineGraph.swift
//  GraphKit
//
//  Created by Håkan Andersson on 19/06/15.
//  Copyright (c) 2015 Fineline. All rights reserved.
//

import UIKit

@objc public protocol LineGraphDatasource: class {
    func numberOfLines(#lineGraph: LineGraph) -> Int
    func lineGraph(#lineGraph: LineGraph, numberOfPointsForLineWithIndex index: Int) -> Int
    func lineGraph(#lineGraph: LineGraph, colorForLineWithIndex index: Int) -> UIColor
    func lineGraph(#lineGraph: LineGraph, pointForLineWithIndex index: Int, position: Int) -> GraphPoint
    optional func lineGraph(#lineGraph: LineGraph, animationDurationForLineWithIndex index: Int) -> Double
}


@IBDesignable public final class LineGraph: UIView {

    private let defaultLabelWidth: CGFloat = 45.0
    private let defaultLabelHeight: CGFloat = 22.0
    private let defaultAxisMargin: CGFloat = 50.0
    private let defaultMargin: CGFloat = 20.0
    private let defaultMarginTop: CGFloat = 20.0
    private let defaultMarginBottom: CGFloat = 20.0

    @IBOutlet final public weak var datasource: LineGraphDatasource?
    
    @IBInspectable final var font: UIFont! = UIFont(name: "HelveticaNeue-Light", size: 14)
    @IBInspectable final var textColor: UIColor! = UIColor.lightGrayColor()
    
    final private var plotLayer: PlotLayer!
    
    final private var valueLabels: [UILabel]!
    final private var titleLabels: [UILabel]!
    final private lazy var lineLayers: [LineLayer] = []
    
    final private var minValue: GraphPoint!
    final private var maxValue: GraphPoint!
    
    private var plotHeight: CGFloat {
        return plotLayer.frame.size.height
    }

    private var plotWidth: CGFloat {
        return plotLayer.frame.size.width
    }

    private var numberOfLines: Int {
        if let count = self.datasource?.numberOfLines(lineGraph: self) {
            return count
        }
        return 0
    }
    private var margin: CGFloat {
        return defaultMargin
    }
    
    public init() {
        super.init(frame: CGRectZero)
        initializeGraph()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeGraph()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initializeGraph()
    }

    private func initializeGraph() {
        let plotLayer = PlotLayer()
        layer.addSublayer(plotLayer)
        self.plotLayer = plotLayer
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        let leadingMargin = margin + defaultAxisMargin
        let plotWidth = (frame.width - leadingMargin - margin)
        let bottomMargin = (2.0 * defaultLabelHeight + defaultMarginBottom)
        let plotHeight = (frame.height - bottomMargin - defaultMarginTop)
        plotLayer.frame = CGRect(x: leadingMargin, y: defaultMarginTop, width: plotWidth, height: plotHeight)
    }
    
    public func drawGraph() {
        clearLines()
        clearLabels()
        updateMinMaxValues()
        createTitleLabels()
        createValueLabels()
        
        let count = numberOfLines
        CATransaction.begin()
        for var i = 0; i < count; ++i {
            drawLineForIndex(i)
        }
        CATransaction.commit()
    }
    
    private func clearLabels() {
        if let labels = titleLabels {
            for label in titleLabels {
                label.removeFromSuperview()
            }
            titleLabels = nil
        }
        if let labels = valueLabels {
            for label in valueLabels {
                label.removeFromSuperview()
            }
            valueLabels = nil
        }
    }
    private func clearLines() {
        plotLayer.clearLineLayers()
        lineLayers.removeAll(keepCapacity: false)
    }
    
    private func updateMinMaxValues() {
        var (minValue, maxValue) = minMaxValues()
        self.minValue = minValue
        self.maxValue = maxValue
    }
    
    //public to be tested
    public func minMaxValues() -> (GraphPoint, GraphPoint) {
        var maxValue: GraphPoint = GraphPoint(x: DBL_MIN, y: DBL_MIN)
        var minValue: GraphPoint = GraphPoint(x: DBL_MAX, y: DBL_MAX)
        let count = numberOfLines
        for var index = 0; index < count; ++index {
            if let numberOfPoints = self.datasource?.lineGraph(lineGraph: self, numberOfPointsForLineWithIndex: index) {
                for var position = 0; position < numberOfPoints; ++position {
                    if let point = self.datasource?.lineGraph(lineGraph: self, pointForLineWithIndex: index, position: position) {
                        maxValue.x = max(maxValue.x, point.x)
                        maxValue.y = max(maxValue.y, point.y)
                        minValue.x = min(minValue.x, point.x)
                        minValue.y = min(minValue.y, point.y)
                    }
                }
            }
        }
        return (minValue, maxValue)
    }

    private func drawLineForIndex(index: Int) {
        var points: [Point] = normalizedPointsForIndex(index)
        let color = self.datasource?.lineGraph(lineGraph: self, colorForLineWithIndex: index)
        let lineLayer = LineLayer(points: points)
        lineLayer.strokeColor = color.or(UIColor.randomColor()).CGColor
        plotLayer.addLineLayer(lineLayer)
        lineLayers.append(lineLayer)
        lineLayer.drawLine()
    }
    
    private func normalizedPointsForIndex(index: Int) -> [Point] {
        var points: [Point] = []
        if let count = self.datasource?.lineGraph(lineGraph: self, numberOfPointsForLineWithIndex: index) {
            for var position = 0; position < count; ++position {
                let graphPoint = self.datasource?.lineGraph(lineGraph: self, pointForLineWithIndex: index, position: position)

                let x: CGFloat = xPositionForValue(graphPoint!.x)
                let y: CGFloat = yPositionForValue(graphPoint!.y)
                
                let point = Point(x: x, y: y)
                points.append(point)
            }
        }
        return points
    }
    
    private func yPositionForValue(value: Double) -> CGFloat {
        let scale = (value - minValue.y) / (maxValue.y - minValue.y)
        return plotHeight * (1.0 - CGFloat(scale))
    }

    private func xPositionForValue(value: Double) -> CGFloat {
        let scale = (value - minValue.x) / (maxValue.x - minValue.x)
        return plotWidth * CGFloat(scale)
    }
    
    private func createTitleLabels() {
        let count = Int((plotWidth + defaultLabelWidth) / defaultLabelWidth)
        var labels: [UILabel] = []
        let step = max(Int(maxValue.x - minValue.x) / (count - 1), 1)
        for var i = Int(minValue.x); i <= Int(maxValue.x); i += step {
            let x = defaultAxisMargin + xPositionForValue(Double(i))
            let y = self.frame.height - (2.0 * defaultLabelHeight)
            let frame = CGRect(x: x, y: y, width: defaultLabelWidth, height: defaultLabelHeight)
            let label = UILabel(frame: frame)
            label.backgroundColor = UIColor.clearColor()
            label.textAlignment = NSTextAlignment.Center
            label.font = font
            label.textColor = textColor
            label.text = "\(i)"
            labels.append(label)
            addSubview(label)
        }
        
        titleLabels = labels
    }
    
    private func createValueLabels() {
        let count = Int((plotHeight + defaultLabelHeight) / defaultLabelHeight)
        let labelHeight = (plotHeight + defaultLabelHeight) / CGFloat(count)
        var labels: [UILabel] = []
        for var i = 0; i < count; ++i {
            let x = margin
            let y = (defaultMarginTop - (defaultLabelHeight / 2.0)) + labelHeight * CGFloat(i)
            let frame = CGRect(x: x, y: y, width: defaultLabelWidth, height: labelHeight)
            let label = UILabel(frame: frame)
            label.backgroundColor = UIColor.clearColor()
            label.textAlignment = NSTextAlignment.Center
            label.font = font
            label.textColor = textColor

            let step = GraphPoint.yStepCalculation(maxValue, minValue: minValue, count: count, i: i)
            label.text = "\(step)"
            labels.append(label)
            addSubview(label)
        }
        self.valueLabels = labels
    }

}


