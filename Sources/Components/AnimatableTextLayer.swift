//
//  AnimatableTextLayer.swift
//  SuggestionsKit
//
//  Created by huemae on 06.05.2020.
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


class AnimatableTextLayer: CATextLayer {
    
    private var config: SuggestionsConfig
    private var animationDuration: TimeInterval = 0
    private var nextString: NSAttributedString = .init()
    private var nextSize: StringSizeCalculator.TextSizeItem = .init(lines: [], size: .zero, alignment: .left)
    
    init(with config: SuggestionsConfig) {
        let layer = CATextLayer()
        self.config = config
        super.init(layer: layer)
    }
    
    override init(layer: Any) {
        self.config = SuggestionsConfig()
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(in ctx: CGContext) {
        let context = ctx
        
        context.setAllowsAntialiasing(true)
        
        context.setAllowsFontSmoothing(false)
        context.setShouldSmoothFonts(false)
        
        context.setAllowsFontSubpixelPositioning(false)
        context.setShouldSubpixelPositionFonts(false)
        
        context.setAllowsFontSubpixelQuantization(true)
        context.setShouldSubpixelQuantizeFonts(true)
        
                    
        let textMatrix = context.textMatrix
        let textPosition = context.textPosition
        
        context.textMatrix = CGAffineTransform(scaleX: 1.0, y: -1.0)
        
        let alignment = nextSize.alignment
        let offset = CGPoint.zero
        
        for i in 0 ..< nextSize.lines.count {
            let line = nextSize.lines[i]
            
            var lineFrame = line.frame
            lineFrame.origin.y += offset.y
            
            if alignment == .left {
                lineFrame.origin.x = 0
            } else if alignment == .right {
                lineFrame.origin.x = offset.x + floor(bounds.size.width - lineFrame.width)
			} else if alignment == .center {
				lineFrame.origin.x = offset.x + floor(bounds.size.width - lineFrame.width) / 2
			}
            context.textPosition = CGPoint(x: lineFrame.minX, y: lineFrame.minY)
            CTLineDraw(line.line, context)
        }
        context.textMatrix = textMatrix
        context.textPosition = CGPoint(x: textPosition.x, y: textPosition.y)
        
        context.setBlendMode(.normal)
    }
    
    private func displayLineFrame(frame: CGRect, isRTL: Bool, boundingRect: CGRect) -> CGRect {
        if frame.width.isEqual(to: boundingRect.width) {
            return frame
        }
        var lineFrame = frame
        if isRTL {
            lineFrame.origin.x = max(0.0, floor(boundingRect.width - lineFrame.size.width))
        }
        return lineFrame
    }
    
    func updateNextAnimationDuration(duration: TimeInterval) {
        animationDuration = duration
    }
    
    func updateInfo(text: NSAttributedString, size: StringSizeCalculator.TextSizeItem) {
        nextSize = size
        nextString = text
        setNeedsDisplay()
    }
    
    override func action(forKey event: String) -> CAAction? {
        let curAnim = super.action(forKey: event) as? CAAnimation
        guard let anim = curAnim?.mutableCopy() as? CAAnimation else { return nil }
        anim.timingFunction = CAMediaTimingFunction(name: config.animationsTimingFunction)
        anim.duration = animationDuration
        anim.fillMode = .forwards
        
        return anim
    }
    
    override func removeAnimation(forKey key: String) {
        super.removeAnimation(forKey: key)
        
    }
	
	override var zPosition: CGFloat {
		get {
			return super.zPosition
		}
		
		set {
			super.zPosition = newValue
		}
	}
}
