//
//  TextLayer.swift
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


class TextLayer {

    var suggestionFrameClosue: ((Suggestion) -> CGRect)?
    var textLayerUpdatedFrameClosue: ((CGRect) -> ())?
    
    private let config: SuggestionsConfig
    private let layer: AnimatableTextLayer
    
    init(parent: CALayer, config: SuggestionsConfig) {
        self.config = config
        layer = AnimatableTextLayer(with: config)
        commonInit(parent: parent, config: config)
    }
    
    func update(boundsForDrawing: CGRect, maxTextWidth: CGFloat, suggestion: Suggestion, animationDuration: TimeInterval) {
        internalUpdate(boundsForDrawing: boundsForDrawing, maxTextWidth: maxTextWidth, suggestion: suggestion, animationDuration: animationDuration)
    }
}

private extension TextLayer {

    func internalUpdate(boundsForDrawing: CGRect, maxTextWidth: CGFloat, suggestion: Suggestion, animationDuration: TimeInterval) {
        let attrs = [NSAttributedString.Key.font: config.text.font, NSAttributedString.Key.foregroundColor: config.text.textColor]
        let newString = NSAttributedString(string: suggestion.text, attributes: attrs)
        let size = suggestion.text.calculateHeight(textFont: config.text.font, maxWidth: maxTextWidth)
        let newSize = size.size
        
        let suggFrame: CGRect = suggestionFrameClosue?(suggestion) ?? .zero
        
        let isRight = suggFrame.midX > boundsForDrawing.width / 2
        layer.bounds = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        let newAlignment = isRight ? NSTextAlignment.right : NSTextAlignment.left
        
        
        let boundsToDraw: CGRect = boundsForDrawing
        var newFrame = CGRect(x: suggFrame.origin.x, y: suggFrame.origin.y, width: newSize.width, height: newSize.height)
        
        let shouldDrawBuble = config.buble.shouldDraw
        
        let yPositionAbove: CGFloat = {
            var original = suggFrame.minY - newSize.height
            if shouldDrawBuble {
                original -= config.buble.tailHeight + config.buble.focusOffset + SuggestionsObject.Constant.bubleOffset
            } else {
                original -= config.text.holeOffset
            }
            
            return original
        }()
        let yPositionUnder: CGFloat = {
            var original = suggFrame.maxY
            if shouldDrawBuble {
                original += config.buble.tailHeight + config.buble.focusOffset + SuggestionsObject.Constant.bubleOffset
            } else {
                original += config.text.holeOffset
            }
            
            return original
        }()
        
        let xPosition: CGFloat = {
            var calcX = suggFrame.midX - newSize.width / 2
            let maxCalcX = calcX + newSize.width
            if calcX < boundsToDraw.minX {
                calcX = boundsToDraw.minX + SuggestionsObject.Constant.spaceBetweenOverlayAndText
            } else if maxCalcX > boundsToDraw.maxX {
                calcX = boundsToDraw.maxX - newSize.width - SuggestionsObject.Constant.spaceBetweenOverlayAndText
            }
            return calcX
        }()
        
        let prefAppearance = config.preferredTextAppearance
        
        if prefAppearance == .above {
            newFrame.origin.y = yPositionAbove - newSize.height > boundsToDraw.minY ? yPositionAbove : yPositionUnder
        } else if prefAppearance == .under {
            newFrame.origin.y = yPositionUnder + newSize.height < boundsToDraw.maxY ? yPositionUnder : yPositionAbove
        }
        newFrame.origin.x = xPosition
        
        let isTailAbove = newFrame.origin.y > suggFrame.origin.y
        
        let oldBounds = layer.bounds
        var newBounds = oldBounds
        newBounds.size = newFrame.size
        
        layer.updateNextAnimationDuration(duration: animationDuration)
        
        let superlayerYTransform = layer.superlayer?.presentation()?.affineTransform().ty ?? 0
        
        let finalPoint = CGPoint(x: newFrame.midX, y: newFrame.midY)
        let finalPosition = NSValue(cgPoint: finalPoint)

        let fromPosition = layer.position == .zero ? finalPosition : NSValue(cgPoint: layer.position.applying(.init(translationX: 0, y: superlayerYTransform)))
        
        layer.updateInfo(text: newString, size: .init(lines: size.lines, size: size.size, alignment: newAlignment))
        
        let animations: [AnimationInfo] = [
            .init(key: #keyPath(CATextLayer.position), fromValue: fromPosition, toValue: finalPosition),
            .init(key: #keyPath(CATextLayer.frame), fromValue: NSValue(cgRect: oldBounds), toValue: NSValue(cgRect: newBounds))
        ]
        
        layer.perfrormAnimation(items: animations, timing: config.animationsTimingFunction, duration: animationDuration, fillMode: .forwards, changeValuesClosure: { [weak self] in
            self?.layer.frame = newBounds
            self?.layer.position = finalPoint
        })
        textLayerUpdatedFrameClosue?(newFrame)
        
        if config.shouldBounceAfterMove && !config.buble.shouldDraw {
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
        layer.contentsScale = UIScreen.main.scale
        layer.isWrapped = true
        layer.truncationMode = .none
        layer.name = String(describing: self)
        layer.masksToBounds = true
        
        parent.addSublayer(self.layer)
    }
}
