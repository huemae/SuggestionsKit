//
//  BubleLayer.swift
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


class BubleLayer {
    
    private var layer = ReanimatableLayer()
    private let config: SuggestionsConfig
    
    init(parent: CALayer, config: SuggestionsConfig, tempLayerClosure: (CALayer) -> ()) {
        self.config = config
        commonInit(parent: parent, config: config)
        tempLayerClosure(layer)
    }
    
    func update(textRect: CGRect, holeRect: CGRect, suggestion: Suggestion, animationDuration: TimeInterval) {
        internalUpdate(textRect: textRect, holeRect: holeRect, suggestion: suggestion, animationDuration: animationDuration)
    }
}

private extension BubleLayer {
    
    func internalUpdate(textRect: CGRect, holeRect: CGRect, suggestion: Suggestion, animationDuration: TimeInterval) {
        guard config.buble.shouldDraw else { return }
        
        let triangleHeight: CGFloat = config.buble.tailHeight
        let radius: CGFloat = config.buble.cornerRadius
        let frame = textRect
        let rect = frame.inset(by: UIEdgeInsets(top: -5, left: -5, bottom: -5, right: -5))
        let path = UIBezierPath()
        
        let sugFrame = holeRect
        let isTailAbove = frame.origin.y > sugFrame.origin.y
        
        if isTailAbove {
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            let drawX = sugFrame.midX
            
            path.addLine(to: CGPoint(x: drawX - triangleHeight * 1.5, y: rect.minY))
            path.addLine(to: CGPoint(x: drawX, y: rect.minY - triangleHeight))
            path.addLine(to: CGPoint(x: drawX + triangleHeight * 1.5, y: rect.minY))
            
            
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
            let drawX = sugFrame.midX
            
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            
            //fake
            path.addLine(to: CGPoint(x: drawX - 2, y: rect.minY))
            path.addLine(to: CGPoint(x: drawX - 1, y: rect.minY))
            path.addLine(to: CGPoint(x: drawX, y: rect.minY))
            
            path.addArc(withCenter: CGPoint(x: rect.maxX, y: rect.minY + radius), radius: radius, startAngle: CGFloat(-Double.pi / 2), endAngle: 0, clockwise: true)
            path.addArc(withCenter: CGPoint(x: rect.maxX, y: rect.maxY - radius), radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi / 2), clockwise: true)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: drawX + triangleHeight * 1.5, y: rect.maxY))
            path.addLine(to: CGPoint(x: drawX, y: rect.maxY + triangleHeight))
            path.addLine(to: CGPoint(x: drawX - triangleHeight  * 1.5, y: rect.maxY))
            path.addArc(withCenter: CGPoint(x: rect.minX, y: rect.maxY - radius), radius: radius, startAngle: CGFloat(Double.pi / 2), endAngle: CGFloat(Double.pi), clockwise: true)
            path.addArc(withCenter: CGPoint(x: rect.minX, y: rect.minY + radius), radius: radius, startAngle: CGFloat(Double.pi), endAngle: CGFloat(-Double.pi / 2), clockwise: true)
        }
        
        path.close()
        let oldPath = layer.path ?? path.cgPath
        
        let animations: [AnimationInfo] = [
            .init(key: #keyPath(CAShapeLayer.path), fromValue: oldPath, toValue: path.cgPath),
            .init(key: #keyPath(CAShapeLayer.shadowPath), fromValue: oldPath, toValue: path.cgPath)
        ]
        
        layer.perfrormAnimation(items: animations, timing: config.animationsTimingFunction, duration: animationDuration, fillMode: .forwards, changeValuesClosure: { [weak self] in
            self?.layer.path = path.cgPath
            self?.layer.shadowPath = path.cgPath
        })
        
        if config.shouldBounceAfterMove {
            self.layer.removeAnimation(forKey: "transformAnimation")
            
            let transformAnimation = CAKeyframeAnimation(keyPath: "transform")
            let value = isTailAbove ? 15 : -15
            transformAnimation.values = [NSValue(caTransform3D: layer.transform),
                                         NSValue(caTransform3D: CATransform3DMakeAffineTransform(.init(translationX: 0, y: CGFloat(value)))),
                                         NSValue(caTransform3D: layer.transform)]
            
            transformAnimation.repeatCount = .infinity
            transformAnimation.duration = 1.5
            transformAnimation.beginTime = layer.convertTime(CACurrentMediaTime(), from: nil) + animationDuration
            transformAnimation.timingFunctions = [CAMediaTimingFunction(name: .easeInEaseOut), CAMediaTimingFunction(name: .easeInEaseOut), CAMediaTimingFunction(name: .easeInEaseOut)]
            transformAnimation.keyTimes = [0, 0.5, 1]
            layer.add(transformAnimation, forKey: "transformAnimation")
        }
    }
    
    func commonInit(parent: CALayer, config: SuggestionsConfig) {
        layer.fillRule = CAShapeLayerFillRule.evenOdd
        layer.contentsScale = UIScreen.main.scale
        layer.strokeColor = config.buble.borderColor.cgColor
        layer.lineWidth = config.buble.borderWidth
        layer.fillColor = config.buble.backgroundColor.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.name = String(describing: self)
        
        parent.addSublayer(layer)
    }
}


class ReanimatableLayer: CAShapeLayer {
    
    private var tempAnimation: CAAnimation?
    private var tempAnimationKey: String?
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(back), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(front), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func back() {
        let anim = animationKeys()?.compactMap { (animation(forKey: $0), $0) }.first
        removeAllAnimations()
        tempAnimationKey = anim?.1
        tempAnimation = anim?.0?.mutableCopy() as? CAAnimation
    }
    
    @objc func front() {
        guard let anim = tempAnimation, let key = tempAnimationKey else { return }
        add(anim, forKey: key)
    }
}
