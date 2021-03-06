//
//  LineGraph.swift
//  GraphKit
//
//  Created by Håkan Andersson on 19/06/15.
//  Copyright (c) 2015 Fineline. All rights reserved.
//

import UIKit

public protocol LineGraphDatasource: class {
    func numberOfLines(lineGraph: LineGraph) -> Int
    func lineGraph(_ lineGraph: LineGraph, numberOfPointsForLineWithIndex index: Int) -> Int
    func lineGraph(_ lineGraph: LineGraph, colorForLineWithIndex index: Int) -> UIColor
    func lineGraph(_ lineGraph: LineGraph, pointForLineWithIndex index: Int, position: Int) -> GraphPoint
    func lineGraph(_ lineGraph: LineGraph, animationDurationForLineWithIndex index: Int) -> Double
    func lineGraph(_ lineGraph: LineGraph, titleForYValue value: Double, index: Int) -> String?
    func lineGraph(_ lineGraph: LineGraph, titleForXValue value: Double, position: Int) -> String?
    
    func notEnoughPointsToShowMessageForLineGraph(lineGraph: LineGraph) -> String?
    func fractionForSpacingInLineGraph(lineGraph: LineGraph) -> Double?
    func lineGraph(lineGraph: LineGraph, minimumPointsToShowForIndex index: Int) -> Int
}


@IBDesignable public final class LineGraph: UIView {

    fileprivate let defaultLabelWidth: CGFloat = 50.0
    fileprivate let defaultLabelHeight: CGFloat = 25.0
    fileprivate let defaultAxisMargin: CGFloat = 50.0
    fileprivate let defaultMargin: CGFloat = 20.0
    fileprivate let defaultMarginTop: CGFloat = 20.0
    fileprivate let defaultMarginBottom: CGFloat = 20.0
    fileprivate let defaultLabelPadding: CGFloat = 5.0

    public final weak var datasource: LineGraphDatasource?
    
    @IBInspectable final var font: UIFont! = UIFont(name: "HelveticaNeue-Light", size: 14)
    @IBInspectable final var textColor: UIColor! = UIColor.lightGray
    
    fileprivate final var plotLayer: PlotLayer!
    fileprivate final var messageLabel: UILabel!
    
    fileprivate final var valueLabels: [UILabel]!
    fileprivate final var titleLabels: [UILabel]!
    fileprivate final lazy var lineLayers: [LineLayer] = []
    
    fileprivate final var minValue: GraphPoint!
    fileprivate final var maxValue: GraphPoint!
    
    fileprivate final var plotHeight: CGFloat {
        return plotLayer.frame.size.height
    }

    fileprivate final var plotWidth: CGFloat {
        return plotLayer.frame.size.width
    }

    fileprivate final var hasValidValues: Bool {
        return numberOfLines > 0
    }
    fileprivate final var numberOfLines: Int {
        guard let count = self.datasource?.numberOfLines(lineGraph: self) else {
            return 0
        }
        return count
    }
    fileprivate final var margin: CGFloat {
        return defaultMargin
    }
    
    public init() {
        super.init(frame: CGRect.zero)
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

    fileprivate func initializeGraph() {
        let plotLayer = PlotLayer()
        plotLayer.isHidden = true
        layer.addSublayer(plotLayer)
        self.plotLayer = plotLayer
        setupMessageLabel()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let leadingMargin = margin + defaultAxisMargin
        let plotWidth = (frame.width - leadingMargin - (2 * margin))
        let bottomMargin = (defaultLabelHeight + defaultMarginBottom)
        let plotHeight = (frame.height - bottomMargin - defaultMarginTop)
        plotLayer.frame = CGRect(x: leadingMargin, y: defaultMarginTop, width: plotWidth, height: plotHeight)
        messageLabel.frame = CGRect(x: plotLayer.frame.origin.x + defaultLabelPadding, y: plotLayer.frame.origin.y + defaultLabelPadding, width: plotLayer.frame.size.width - 2 * defaultLabelPadding, height: plotLayer.frame.size.height - 2 * defaultLabelPadding)
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
        plotLayer.isHidden = false
        for i in 0 ..< count {
            successfullyDrawnGraph = drawLineForIndex(i) || successfullyDrawnGraph
        }
        CATransaction.commit()
        showMessageLabel(!successfullyDrawnGraph)
    }
    
    fileprivate func showMessageLabel(_ show: Bool) {
        let title = self.datasource?.notEnoughPointsToShowMessageForLineGraph(lineGraph: self)
        messageLabel.text = title
        UIView.animate(withDuration: 0.25, animations: {
            self.messageLabel.alpha = (show ? 1.0 : 0.0)
        }) 
    }
    
    fileprivate func setupMessageLabel() {
        let label = UILabel(frame: plotLayer.frame)
        label.backgroundColor = UIColor.clear
        label.textAlignment = NSTextAlignment.center
        label.font = font
        label.textColor = textColor
        label.alpha = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 0
        addSubview(label)
        self.messageLabel = label
    }
    
    fileprivate func clearLabels() {
        if let labels = titleLabels {
            for label in labels {
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    label.alpha = 0
                    }, completion: { (_) -> Void in
                        label.removeFromSuperview()
                })
            }
            titleLabels = nil
        }
        if let labels = valueLabels {
            for label in labels {
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    label.alpha = 0
                    }, completion: { (_) -> Void in
                        label.removeFromSuperview()
                })
            }
            valueLabels = nil
        }
    }
    fileprivate func clearLines() {
        plotLayer.clearLineLayers()
        lineLayers.removeAll(keepingCapacity: false)
    }
    
    fileprivate final func updateMinMaxValues() {
        let (minValue, maxValue) = minMaxValues()
        guard let fraction = self.datasource?.fractionForSpacingInLineGraph(lineGraph: self), fraction >= 0 && fraction <= 1 else {
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
        guard let datasource = self.datasource else {
            return (minValue, maxValue)
        }
        
        let count = numberOfLines
        for index in 0 ..< count {
            
            let numberOfPoints = datasource.lineGraph(self, numberOfPointsForLineWithIndex: index)
            for position in 0 ..< numberOfPoints {
                let point = datasource.lineGraph(self, pointForLineWithIndex: index, position: position)
                maxValue.x = max(maxValue.x, point.x)
                maxValue.y = max(maxValue.y, point.y)
                minValue.x = min(minValue.x, point.x)
                minValue.y = min(minValue.y, point.y)
            }
        }
        return (minValue, maxValue)
    }

    fileprivate final func drawLineForIndex(_ index: Int) -> Bool{
        let points: [Point] = normalizedPointsForIndex(index)
        guard let minCount = self.datasource?.lineGraph(lineGraph: self, minimumPointsToShowForIndex: index), points.count > minCount else {
            return false
        }
        
        let color = self.datasource?.lineGraph(self, colorForLineWithIndex: index)
        let lineLayer = LineLayer(points: points)
        lineLayer.strokeColor = color.or(UIColor.randomColor()).cgColor
        plotLayer.addLineLayer(lineLayer)
        lineLayers.append(lineLayer)
        lineLayer.drawLine()
        return true
    }
    
    fileprivate final func normalizedPointsForIndex(_ index: Int) -> [Point] {
        guard let count = self.datasource?.lineGraph(self, numberOfPointsForLineWithIndex: index) else {
            return []
        }
        var points: [Point] = []
        for position in 0 ..< count {
            let graphPoint = self.datasource?.lineGraph(self, pointForLineWithIndex: index, position: position)
            
            let x: CGFloat = xPositionForValue(graphPoint!.x)
            let y: CGFloat = yPositionForValue(graphPoint!.y)
            
            let point = Point(x: x, y: y)
            points.append(point)
        }
        return points
    }
    
    fileprivate final func yPositionForValue(_ value: Double) -> CGFloat {
        let scale = (value - minValue.y) / (maxValue.y - minValue.y)
        return plotHeight * (1.0 - CGFloat(scale))
    }

    fileprivate final func xPositionForValue(_ value: Double) -> CGFloat {
        let delta = maxValue.x - minValue.x
        let scale = delta <= 0 ? 0.5 : (value - minValue.x) / delta
        return plotWidth * CGFloat(scale)
    }
    
    fileprivate final func createTitleLabels() {
        if !hasValidValues {
            return
        }
        let count = Int((plotWidth + defaultLabelWidth) / defaultLabelWidth)
        let additionalLeftSpacing: CGFloat = -3.0
        var labels: [UILabel] = []
        let step = max(Int(maxValue.x - minValue.x) / (count - 1), 1)
        for i in stride(from: Int(minValue.x), to: Int(maxValue.x), by: step) {
        //for var i = Int(minValue.x); i <= ; i += step {
            let x = defaultAxisMargin + xPositionForValue(Double(i)) + additionalLeftSpacing
            let y = self.frame.height - (1.5 * defaultLabelHeight)
            let frame = CGRect(x: x, y: y, width: defaultLabelWidth, height: defaultLabelHeight)
            let label = UILabel(frame: frame)
            label.backgroundColor = UIColor.clear
            label.textAlignment = NSTextAlignment.center
            label.font = font
            label.textColor = textColor
            let title = self.datasource?.lineGraph(self, titleForXValue: Double(i), position: labels.count)
            label.text = title ?? "\(i)"
            labels.append(label)
            label.alpha = 0
            addSubview(label)
            UIView.animate(withDuration: 0.35, animations: {
                label.alpha = 1
            }) 

        }
        
        titleLabels = labels
    }
    
    fileprivate final func numberOfYLabels() -> Int {
        return Int((plotHeight + defaultLabelHeight) / defaultLabelHeight)
    }
    
    fileprivate final func createValueLabels() {
        if !hasValidValues {
            return
        }
        let count = numberOfYLabels()
        let labelHeight = (plotHeight + defaultLabelHeight) / CGFloat(count)
        var labels: [UILabel] = []
        for i in 0 ..< count {
            let x = margin
            let y = (defaultMarginTop - (defaultLabelHeight / 2.0)) + labelHeight * CGFloat(i)
            let frame = CGRect(x: x, y: y, width: defaultLabelWidth, height: labelHeight)
            let label = UILabel(frame: frame)
            label.backgroundColor = UIColor.clear
            label.textAlignment = NSTextAlignment.center
            label.font = font
            label.textColor = textColor
            let step = GraphPoint.yStepCalculation(maxValue, minValue: minValue, count: count, i: i)
            let title = self.datasource?.lineGraph(self, titleForYValue: step, index: i)
            label.text = title ?? "\(step)"
            labels.append(label)
            label.alpha = 0
            addSubview(label)
            UIView.animate(withDuration: 0.35, animations: {
                label.alpha = 1
            }) 
        }
        self.valueLabels = labels
    }

}


