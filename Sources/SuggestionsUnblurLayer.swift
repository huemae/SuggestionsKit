//
//  SuggestionsUnblurLayer.swift
//  Suggestions
//
//  Created by ilyailusha on 12.04.2020.
//  Copyright © 2020 ilyailusha. All rights reserved.
//

import Foundation
import UIKit


class SuggestionsUnblurLayer {
    
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

private extension SuggestionsUnblurLayer {
    
    func commonInit(maskedLayer: CALayer, superBunds: CGRect) {
        layer.isGeometryFlipped = true
        layer.contentsScale = UIScreen.main.scale
        layer.frame = superBunds
        layer.fillRule = .evenOdd
        maskedLayer.mask = layer
    }
}
