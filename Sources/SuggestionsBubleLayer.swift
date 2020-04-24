//
//  SuggestionsBubleLayer.swift
//  Suggestions
//
//  Created by ilyailusha on 09.04.2020.
//  Copyright © 2020 ilyailusha. All rights reserved.
//

import Foundation
import UIKit

class SuggestionsBubleLayer {
    
    private var layer = CAShapeLayer()
    private var config: SuggestionsObject.Config!
    
    init(parent: CALayer, config: SuggestionsObject.Config, tempLayerClosure: (CALayer) -> ()) {
        self.config = config
        commonInit(parent: parent, config: config)
    }
    
    func update(textRect: CGRect, holeRect: CGRect, suggestion: SuggestionsManager.Suggestion, animationDuration: TimeInterval) {
        internalUpdate(textRect: textRect, holeRect: holeRect, suggestion: suggestion, animationDuration: animationDuration)
    }
}

private extension SuggestionsBubleLayer {
    
    func internalUpdate(textRect: CGRect, holeRect: CGRect, suggestion: SuggestionsManager.Suggestion, animationDuration: TimeInterval) {
        guard config.buble.shouldDraw else { return }
        
        let triangleHeight: CGFloat = config.buble.tailHeight
        let radius: CGFloat = config.buble.cornerRadius
        let frame = textRect
        let borderWidth: CGFloat = config.buble.borderWidth
        let rect = frame.inset(by: UIEdgeInsets(top: -5, left: -5, bottom: -5, right: -5))
        let path = UIBezierPath()
        
        let radius2 = radius - borderWidth / 2 // Radius adjasted for the border width
        let sugFrame = holeRect
        let isTailAbove = frame.origin.y > sugFrame.origin.y
        
        if isTailAbove {
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            let sss = sugFrame.width / 2
            let left = frame.origin.x - sugFrame.origin.x
            let drawX = rect.origin.x + sss - left + triangleHeight
            
            path.addLine(to: CGPoint(x: drawX - triangleHeight * 3, y: rect.minY))
            path.addLine(to: CGPoint(x: drawX - triangleHeight, y: rect.minY - radius2 - triangleHeight))
            path.addLine(to: CGPoint(x: drawX + triangleHeight, y: rect.minY))
            
            
            path.addArc(withCenter: CGPoint(x: rect.maxX, y: rect.minY + radius), radius: radius, startAngle: CGFloat(-Double.pi / 2), endAngle: 0, clockwise: true)
            path.addArc(withCenter: CGPoint(x: rect.maxX, y: rect.maxY - radius), radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi / 2), clockwise: true)
            //fake
            path.addLine(to: CGPoint(x: drawX + 1, y: rect.maxY))
            path.addLine(to: CGPoint(x: drawX + 2, y: rect.maxY))
            path.addLine(to: CGPoint(x: drawX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            
            path.addArc(withCenter: CGPoint(x: rect.minX, y: rect.maxY - radius), radius: radius, startAngle: CGFloat(Double.pi / 2), endAngle: CGFloat(Double.pi), clockwise: true)
            path.addArc(withCenter: CGPoint(x: rect.minX, y: rect.minY + radius), radius: radius, startAngle: CGFloat(Double.pi), endAngle: CGFloat(-Double.pi / 2), clockwise: true)
        } else {
            let sss = sugFrame.width / 2
            let left = frame.origin.x - sugFrame.origin.x
            let drawX = rect.origin.x + sss - left + triangleHeight
            
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            
            //fake
            path.addLine(to: CGPoint(x: drawX - 2, y: rect.minY))
            path.addLine(to: CGPoint(x: drawX - 1, y: rect.minY))
            path.addLine(to: CGPoint(x: drawX, y: rect.minY))
            
            path.addArc(withCenter: CGPoint(x: rect.maxX, y: rect.minY + radius), radius: radius, startAngle: CGFloat(-Double.pi / 2), endAngle: 0, clockwise: true)
            path.addArc(withCenter: CGPoint(x: rect.maxX, y: rect.maxY - radius), radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi / 2), clockwise: true)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: drawX + triangleHeight * 3, y: rect.maxY))
            path.addLine(to: CGPoint(x: drawX + triangleHeight, y: rect.maxY + radius2 + triangleHeight))
            path.addLine(to: CGPoint(x: drawX - triangleHeight, y: rect.maxY))
            path.addArc(withCenter: CGPoint(x: rect.minX, y: rect.maxY - radius), radius: radius, startAngle: CGFloat(Double.pi / 2), endAngle: CGFloat(Double.pi), clockwise: true)
            path.addArc(withCenter: CGPoint(x: rect.minX, y: rect.minY + radius), radius: radius, startAngle: CGFloat(Double.pi), endAngle: CGFloat(-Double.pi / 2), clockwise: true)
        }
        
        path.close()
        let oldPath = layer.path ?? CGPath(roundedRect: .zero, cornerWidth: 0, cornerHeight: 0, transform: nil)
        
        let opacityAnimation = CAKeyframeAnimation(keyPath:"opacity")
        opacityAnimation.values = [1,0,1]
        opacityAnimation.keyTimes = [0,0.5,1]
        
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = oldPath
        pathAnimation.toValue = path.cgPath
        
        let shadowPathAnimation = CABasicAnimation(keyPath: "shadowPath")
        shadowPathAnimation.fromValue = oldPath
        shadowPathAnimation.toValue = path.cgPath
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [pathAnimation, opacityAnimation, shadowPathAnimation]
        groupAnimation.fillMode = .forwards
        groupAnimation.duration = animationDuration
        groupAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        groupAnimation.isRemovedOnCompletion = true
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            self?.layer.removeAnimation(forKey: "path")
            self?.layer.removeAnimation(forKey: "opacity")
            self?.layer.removeAnimation(forKey: "shadowPath")
        }
        layer.add(groupAnimation, forKey: "groupAnimation")
        layer.path = path.cgPath
        layer.shadowPath = path.cgPath
        CATransaction.commit()
    }
    
    func commonInit(parent: CALayer, config: SuggestionsObject.Config) {
        layer.fillRule = CAShapeLayerFillRule.evenOdd
        layer.contentsScale = UIScreen.main.scale
        layer.strokeColor = config.buble.borderColor.cgColor
        layer.lineWidth = config.buble.borderWidth
        layer.fillColor = config.buble.backgroundColor.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1)
        
        parent.addSublayer(layer)
    }
}

