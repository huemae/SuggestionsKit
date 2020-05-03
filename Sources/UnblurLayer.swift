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
    
    init(maskedLayer: CALayer, superBunds: CGRect) {
        commonInit(maskedLayer: maskedLayer, superBunds: superBunds)
    }
    
    func updateUnblur(suggestion: SuggestionsManager.Suggestion, holeRect: CGRect, animationDuration: TimeInterval) {
        let biggerRect = CGRect(x: layer.frame.origin.x, y: layer.frame.origin.y, width: layer.frame.size.width, height: layer.frame.size.height)
        let smallerRect = holeRect

        let maskPath = UIBezierPath()
        maskPath.move(to: CGPoint(x: biggerRect.minX, y: biggerRect.minY))
        maskPath.addLine(to: CGPoint(x: biggerRect.minX, y: biggerRect.maxY))
        maskPath.addLine(to: CGPoint(x: biggerRect.maxX, y: biggerRect.maxY))
        maskPath.addLine(to: CGPoint(x: biggerRect.maxX, y: biggerRect.minY))
        maskPath.addLine(to: CGPoint(x: biggerRect.minX, y: biggerRect.minY))

        maskPath.move(to: CGPoint(x: smallerRect.minX, y: smallerRect.minY))
        maskPath.addLine(to: CGPoint(x: smallerRect.minX, y: smallerRect.maxY))
        maskPath.addLine(to: CGPoint(x: smallerRect.maxX, y: smallerRect.maxY))
        maskPath.addLine(to: CGPoint(x: smallerRect.maxX, y: smallerRect.minY))
        maskPath.addLine(to: CGPoint(x: smallerRect.minX, y: smallerRect.minY))
        
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = layer.path
        pathAnimation.toValue = maskPath.cgPath
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [pathAnimation]
        groupAnimation.fillMode = .forwards
        groupAnimation.duration = animationDuration
        groupAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        groupAnimation.isRemovedOnCompletion = true
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            self?.layer.removeAnimation(forKey: "path")
        }
        layer.add(groupAnimation, forKey: "groupAnimation")
        layer.path = maskPath.cgPath
        CATransaction.commit()
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
