//
//  FillLayer.swift
//  Suggestions
//
//  Created by huemae on 12.04.2020.
//  Copyright (c) 2020 huemae <ilyailusha@hotmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import UIKit


class FillLayer {
    
    var suggestionFrameClosue: ((Suggestion) -> CGRect)?
    var holeRectUpdatedClosue: ((CGRect) -> ())?
    var holeMoveDurationUpdatedClosue: ((TimeInterval) -> ())?
    
    private let layer = CAShapeLayer()
    private var mainPath: UIBezierPath = UIBezierPath()
    private var lastHolePath: UIBezierPath?
    private var holeRect: CGRect = .zero
    private var animationDuration: TimeInterval = 0
    private let config: SuggestionsConfig
    
    init(parent: CALayer, config: SuggestionsConfig) {
        self.config = config
        commonInit(parent: parent, config: config)
        recreateMainPath(parentBounds: parent.bounds)
    }
    
    func update(suggestion: Suggestion, parentBounds: CGRect) {
        recreateMainPath(parentBounds: parentBounds)
        internalUpdate(suggestion: suggestion)
    }
}

private extension FillLayer {
    
    func recreateMainPath(parentBounds: CGRect) {
        let newMainPath = UIBezierPath(rect: .init(origin: .zero, size: .init(width: 10000, height: 10000)))
        mainPath = newMainPath
    }
    
    func internalUpdate(suggestion: Suggestion) {
        guard let view = suggestion.view else { return }
        layer.path = mainPath.cgPath
        let sugFrame = suggestionFrameClosue?(suggestion) ?? .zero
        let width = sugFrame.width + SuggestionsObject.Constant.holeOverdrawAmount
        let height = sugFrame.height + SuggestionsObject.Constant.holeOverdrawAmount
        
        let halfOverdraw = SuggestionsObject.Constant.holeOverdrawAmount / 2
        
        holeRect = CGRect(x: sugFrame.origin.x - halfOverdraw, y: sugFrame.origin.y - halfOverdraw, width: width, height: height)
        
        let finalRadius: CGFloat = {
            let sugRadius = view.layer.cornerRadius
            if sugRadius > 0 {
                if sugRadius == sugFrame.size.height / 2 {
                    return holeRect.width / 2
                }
                return sugRadius
            }
            
            return SuggestionsObject.Constant.minimalCornerRadius
        }()
        
        let fakeNewPath = mainPath.copy() as? UIBezierPath ?? UIBezierPath()
        
        if let lastPath = lastHolePath {
            fakeNewPath.append(lastPath)
        } else {
            let fakePath = UIBezierPath(roundedRect: holeRect, cornerRadius: finalRadius)
            fakeNewPath.append(fakePath)
        }

        holeRectUpdatedClosue?(holeRect)
        let circlePath = UIBezierPath(roundedRect: holeRect, cornerRadius: finalRadius)
        self.lastHolePath = circlePath
        let newPath = mainPath.copy() as? UIBezierPath ?? UIBezierPath()
        newPath.append(circlePath)
        
        animationDuration = calculateDuration(distance: CGPointDistance(from: fakeNewPath.currentPoint, to: newPath.currentPoint))
        holeMoveDurationUpdatedClosue?(animationDuration)
        
        let animations: [AnimationInfo] = [
            .init(key: #keyPath(CAShapeLayer.path), fromValue: fakeNewPath.cgPath, toValue: newPath.cgPath)
        ]
        
        layer.perfrormAnimation(items: animations, timing: config.animationsTimingFunction, duration: animationDuration, fillMode: .forwards, changeValuesClosure: { [weak self] in
            self?.layer.path = newPath.cgPath
        })
    }
    
    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }
    
    func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(from: from, to: to))
    }
    
    func calculateDuration(distance: CGFloat) -> Double {
        return 0.5
    }
    
    func commonInit(parent: CALayer, config: SuggestionsConfig) {
        layer.fillRule = CAShapeLayerFillRule.evenOdd
        layer.contentsScale = UIScreen.main.scale
        layer.fillColor = config.background.color.cgColor
        layer.name = String(describing: self)
        layer.opacity = Float(config.background.opacity)
        
        parent.addSublayer(layer)
    }
}
