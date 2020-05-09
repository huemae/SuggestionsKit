//
//  UnblurLayer.swift
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


class UnblurLayer {
    
    private let layer = CAShapeLayer()
    private let config: SuggestionsConfig
    
    init(maskedLayer: CALayer, superBunds: CGRect, config: SuggestionsConfig) {
        self.config = config
        commonInit(maskedLayer: maskedLayer, superBunds: superBunds)
    }
    
    func update(frame: CGRect) {
        layer.frame = frame
    }
    
    func updateUnblur(suggestion: Suggestion, holeRect: CGRect, animationDuration: TimeInterval) {
        let biggerRect = CGRect(x: layer.frame.origin.x, y: layer.frame.origin.y, width: layer.frame.size.width, height: layer.frame.size.height)
        let smallerRect = holeRect
        
        let finalRadius: CGFloat = {
            let sugRadius = suggestion.view.layer.cornerRadius
            if sugRadius > 0 {
                if sugRadius == suggestion.view.frame.size.height / 2 {
                    return holeRect.width / 2
                }
                return sugRadius
            }
            
            return SuggestionsObject.Constant.minimalCornerRadius
        }()

        let maskPath = UIBezierPath(roundedRect: biggerRect, cornerRadius: 0)
        maskPath.append(UIBezierPath(roundedRect: smallerRect, cornerRadius: finalRadius))
        
        let animations: [AnimationInfo] = [
            .init(key: #keyPath(CAShapeLayer.path), fromValue: layer.path, toValue: maskPath.cgPath)
        ]
        
        layer.perfrormAnimation(items: animations, timing: config.animationsTimingFunction, duration: animationDuration, fillMode: .forwards, changeValuesClosure: { [weak self] in
            self?.layer.path = maskPath.cgPath
        })
    }
}

private extension UnblurLayer {
    
    func commonInit(maskedLayer: CALayer, superBunds: CGRect) {
        layer.isGeometryFlipped = true
        layer.contentsScale = UIScreen.main.scale
        layer.frame = superBunds
        layer.fillRule = .evenOdd
        layer.name = String(describing: self)
        
        maskedLayer.mask = layer
    }
}
