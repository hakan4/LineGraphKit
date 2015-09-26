//
//  LineGraph.swift
//  GraphKit
//
//  Created by Håkan Andersson on 19/06/15.
//  Copyright (c) 2015 Fineline. All rights reserved.
//

import UIKit

public protocol LineGraphDatasource: class {
    func numberOfLines(lineGraph lineGraph: LineGraph) -> Int
    func lineGraph(lineGraph lineGraph: LineGraph, numberOfPointsForLineWithIndex index: Int) -> Int
    func lineGraph(lineGraph lineGraph: LineGraph, colorForLineWithIndex index: Int) -> UIColor
    func lineGraph(lineGraph lineGraph: LineGraph, pointForLineWithIndex index: Int, position: Int) -> GraphPoint
    func lineGraph(lineGraph lineGraph: LineGraph, animationDurationForLineWithIndex index: Int) -> Double
    func lineGraph(lineGraph lineGraph: LineGraph, titleForYValue value: Double, index: Int) -> String?
    func lineGraph(lineGraph lineGraph: LineGraph, titleForXValue value: Double, position: Int) -> String?
    
    func notEnoughPointsToShowMessageForLineGraph(lineGraph lineGraph: LineGraph) -> String?
    func fractionForSpacingInLineGraph(lineGraph lineGraph: LineGraph) -> Double?
    func lineGraph(lineGraph lineGraph: LineGraph, minimumPointsToShowForIndex index: Int) -> Int
}


@IBDesignable public final class LineGraph: UIView {

    private let defaultLabelWidth: CGFloat = 45.0
    private let defaultLabelHeight: CGFloat = 25.0
    private let defaultAxisMargin: CGFloat = 50.0
    private let defaultMargin: CGFloat = 20.0
    private let defaultMarginTop: CGFloat = 20.0
    private let defaultMarginBottom: CGFloat = 20.0

    public final weak var datasource: LineGraphDatasource?
    
    @IBInspectable final var font: UIFont! = UIFont(name: "HelveticaNeue-Light", size: 14)
    @IBInspectable final var textColor: UIColor! = UIColor.lightGrayColor()
    
    final private var plotLayer: PlotLayer!
    final private var messageLabel: UILabel!
    
    final private var valueLabels: [UILabel]!
    final private var titleLabels: [UILabel]!
    final private lazy var lineLayers: [LineLayer] = []
    
    final private var minValue: GraphPoint!
    final private var maxValue: GraphPoint!
    
    private final var plotHeight: CGFloat {
        return plotLayer.frame.size.height
    }

    private final var plotWidth: CGFloat {
        return plotLayer.frame.size.width
    }

    private final var numberOfLines: Int {
        guard let count = self.datasource?.numberOfLines(lineGraph: self) else {
            return 0
        }
        return count
    }
    private final var margin: CGFloat {
        return defaultMargin
    }
    
    public init() {
        super.init(frame: CGRectZero)
        initializeGraph()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeGraph()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initializeGraph()
    }

    private func initializeGraph() {
        let plotLayer = PlotLayer()
        plotLayer.hidden = true
        layer.addSublayer(plotLayer)
        self.plotLayer = plotLayer
        setupMessageLabel()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let leadingMargin = margin + defaultAxisMargin
        let plotWidth = (frame.width - leadingMargin - margin)
        let bottomMargin = (defaultLabelHeight + defaultMarginBottom)
        let plotHeight = (frame.height - bottomMargin - defaultMarginTop)
        plotLayer.frame = CGRect(x: leadingMargin, y: defaultMarginTop, width: plotWidth, height: plotHeight)
        messageLabel.frame = plotLayer.frame
    }
    
    public func drawGraph() {
        clearLines()
        clearLabels()
        updateMinMaxValues()
        createTitleLabels()
        createValueLabels()
        
        var successfullyDrawnGraph: Bool = false
        let count = numberOfLines
        CATransaction.begin()
        plotLayer.hidden = false
        for var i = 0; i < count; ++i {
            successfullyDrawnGraph = drawLineForIndex(i) || successfullyDrawnGraph
        }
        CATransaction.commit()
        showMessageLabel(!successfullyDrawnGraph)
    }
    
    private func showMessageLabel(show: Bool) {
        let title = self.datasource?.notEnoughPointsToShowMessageForLineGraph(lineGraph: self)
        messageLabel.text = title
        UIView.animateWithDuration(0.25) {
            self.messageLabel.alpha = (show ? 1.0 : 0.0)
        }
    }
    
    private func setupMessageLabel() {
        let label = UILabel(frame: plotLayer.frame)
        label.backgroundColor = UIColor.clearColor()
        label.textAlignment = NSTextAlignment.Center
        label.font = font
        label.textColor = textColor
        label.alpha = 0
        addSubview(label)
        self.messageLabel = label
    }
    
    private func clearLabels() {
        if let labels = titleLabels {
            for label in labels {
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    label.alpha = 0
                    }, completion: { (_) -> Void in
                        label.removeFromSuperview()
                })
            }
            titleLabels = nil
        }
        if let labels = valueLabels {
            for label in labels {
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    label.alpha = 0
                    }, completion: { (_) -> Void in
                        label.removeFromSuperview()
                })
            }
            valueLabels = nil
        }
    }
    private func clearLines() {
        plotLayer.clearLineLayers()
        lineLayers.removeAll(keepCapacity: false)
    }
    
    private final func updateMinMaxValues() {
        let (minValue, maxValue) = minMaxValues()
        guard let fraction = self.datasource?.fractionForSpacingInLineGraph(lineGraph: self) where fraction >= 0 && fraction <= 1 else {
            self.minValue = minValue
            self.maxValue = maxValue
            return
        }
        let addon = (((maxValue.y - minValue.y) / Double(numberOfYLabels())) * fraction)
        self.minValue = GraphPoint(x: minValue.x, y: max(0, minValue.y - addon))
        self.maxValue = GraphPoint(x: maxValue.x, y: maxValue.y + addon)
    }
    
    //to be tested
    final func minMaxValues() -> (GraphPoint, GraphPoint) {
        let maxValue: GraphPoint = GraphPoint(x: DBL_MIN, y: DBL_MIN)
        let minValue: GraphPoint = GraphPoint(x: DBL_MAX, y: DBL_MAX)
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

    private final func drawLineForIndex(index: Int) -> Bool{
        guard let points: [Point] = normalizedPointsForIndex(index), let minCount = self.datasource?.lineGraph(lineGraph: self, minimumPointsToShowForIndex: index) where points.count > minCount else {
            return false
        }
        let color = self.datasource?.lineGraph(lineGraph: self, colorForLineWithIndex: index)
        let lineLayer = LineLayer(points: points)
        lineLayer.strokeColor = color.or(UIColor.randomColor()).CGColor
        plotLayer.addLineLayer(lineLayer)
        lineLayers.append(lineLayer)
        lineLayer.drawLine()
        return true
    }
    
    private final func normalizedPointsForIndex(index: Int) -> [Point] {
        guard let count = self.datasource?.lineGraph(lineGraph: self, numberOfPointsForLineWithIndex: index) else {
            return []
        }
        var points: [Point] = []
        for var position = 0; position < count; ++position {
            let graphPoint = self.datasource?.lineGraph(lineGraph: self, pointForLineWithIndex: index, position: position)
            
            let x: CGFloat = xPositionForValue(graphPoint!.x)
            let y: CGFloat = yPositionForValue(graphPoint!.y)
            
            let point = Point(x: x, y: y)
            points.append(point)
        }
        return points
    }
    
    private final func yPositionForValue(value: Double) -> CGFloat {
        let scale = (value - minValue.y) / (maxValue.y - minValue.y)
        return plotHeight * (1.0 - CGFloat(scale))
    }

    private final func xPositionForValue(value: Double) -> CGFloat {
        let scale = (value - minValue.x) / (maxValue.x - minValue.x)
        return plotWidth * CGFloat(scale)
    }
    
    private final func createTitleLabels() {
        let count = Int((plotWidth + defaultLabelWidth) / defaultLabelWidth)
        var labels: [UILabel] = []
        let step = max(Int(maxValue.x - minValue.x) / (count - 1), 1)
        for var i = Int(minValue.x); i <= Int(maxValue.x); i += step {
            let x = defaultAxisMargin + xPositionForValue(Double(i))
            let y = self.frame.height - (1.5 * defaultLabelHeight)
            let frame = CGRect(x: x, y: y, width: defaultLabelWidth, height: defaultLabelHeight)
            let label = UILabel(frame: frame)
            label.backgroundColor = UIColor.clearColor()
            label.textAlignment = NSTextAlignment.Center
            label.font = font
            label.textColor = textColor
            let title = self.datasource?.lineGraph(lineGraph: self, titleForXValue: Double(i), position: labels.count)
            label.text = title ?? "\(i)"
            labels.append(label)
            label.alpha = 0
            addSubview(label)
            UIView.animateWithDuration(0.35) {
                label.alpha = 1
            }

        }
        
        titleLabels = labels
    }
    
    private final func numberOfYLabels() -> Int {
        return Int((plotHeight + defaultLabelHeight) / defaultLabelHeight)
    }
    
    private final func createValueLabels() {
        let count = numberOfYLabels()
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
            let title = self.datasource?.lineGraph(lineGraph: self, titleForYValue: step, index: i)
            label.text = title ?? "\(step)"
            labels.append(label)
            label.alpha = 0
            addSubview(label)
            UIView.animateWithDuration(0.35) {
                label.alpha = 1
            }
        }
        self.valueLabels = labels
    }

}


