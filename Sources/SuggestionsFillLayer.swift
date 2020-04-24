//
//  SuggestionsFillLayer.swift
//  Suggestions
//
//  Created by ilyailusha on 09.04.2020.
//  Copyright © 2020 ilyailusha. All rights reserved.
//

import Foundation
import UIKit

class SuggestionsFillLayer {
    
    var suggestionFrameClosue: ((SuggestionsManager.Suggestion) -> CGRect)?
    var holeRectUpdatedClosue: ((CGRect) -> ())!
    var holeMoveDurationUpdatedClosue: ((TimeInterval) -> ())!
    
    private let layer = CAShapeLayer()
    private let mainPath: UIBezierPath
    private var lastHolePath: UIBezierPath?
    private var holeRect: CGRect = .zero
    private var animationDuration: TimeInterval = 0
    
    init(parent: CALayer, config: SuggestionsObject.Config) {
        mainPath = UIBezierPath(rect: parent.bounds)
        commonInit(parent: parent, config: config)
    }
    
    func update(suggestion: SuggestionsManager.Suggestion) {
        internalUpdate(suggestion: suggestion)
    }
}

private extension SuggestionsFillLayer {
    
    func internalUpdate(suggestion: SuggestionsManager.Suggestion) {
        layer.path = mainPath.cgPath
        let sugFrame = suggestionFrameClosue?(suggestion) ?? .zero
        let width = sugFrame.width + SuggestionsObject.Constant.holeOverdrawAmount
        let height = sugFrame.height + SuggestionsObject.Constant.holeOverdrawAmount
        
        let finalRadius = SuggestionsObject.Constant.minimalCornerRadius
        
        let fakeNewPath = mainPath.copy() as! UIBezierPath
        
        if let lastPath = lastHolePath {
            fakeNewPath.append(lastPath)
        } else {
            let space = SuggestionsObject.Constant.spaceBetweenOverlayAndText
            let frame = layer.frame
            let fakePath = UIBezierPath(roundedRect: CGRect(x: frame.midX - space, y: frame.midY - space, width: space * 2, height: space * 2), cornerRadius: space)
            fakeNewPath.append(fakePath)
        }
        
        let halfOverdraw = SuggestionsObject.Constant.holeOverdrawAmount / 2
        
        holeRect = CGRect(x: sugFrame.origin.x - halfOverdraw, y: sugFrame.origin.y - halfOverdraw, width: width, height: height)
        holeRectUpdatedClosue(holeRect)
        let circlePath = UIBezierPath(roundedRect: self.holeRect, cornerRadius: finalRadius)
        self.lastHolePath = circlePath
        let newPath = mainPath.copy() as! UIBezierPath
        newPath.append(circlePath)
        
        animationDuration = calculateDuration(distance: CGPointDistance(from: fakeNewPath.currentPoint, to: newPath.currentPoint))
        holeMoveDurationUpdatedClosue(animationDuration)
        
        let pathAnimation = CAKeyframeAnimation(keyPath: "path")
        pathAnimation.values = [fakeNewPath.cgPath, newPath.cgPath]
        pathAnimation.keyTimes = [0, 1]
        pathAnimation.duration = animationDuration
        pathAnimation.isRemovedOnCompletion = true
        pathAnimation.repeatCount = 1
        pathAnimation.fillMode = .forwards
        pathAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            self?.layer.removeAnimation(forKey: "path")
        }
        layer.add(pathAnimation, forKey: "pathAnimation")
        CATransaction.commit()
        layer.path = newPath.cgPath
    }
    
    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }
    
    func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(from: from, to: to))
    }
    
    func calculateDuration(distance: CGFloat) -> Double {
        let pointsPerSecond: Double = 800.0
        let time = Double(distance) / pointsPerSecond
        let calculatedTime = Double(time)
        
        return calculatedTime
    }
    
    func commonInit(parent: CALayer, config: SuggestionsObject.Config) {
        layer.fillRule = CAShapeLayerFillRule.evenOdd
        layer.contentsScale = UIScreen.main.scale
        layer.fillColor = config.background.color.cgColor
        layer.opacity = Float(config.background.opacity)
        
        parent.addSublayer(layer)
    }
}
