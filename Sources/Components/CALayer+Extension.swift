//
//  CALayer+Extension.swift
//  SuggestionsKit
//
//  Created by huemae on 09.05.2020.
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


extension CALayer {
    
    func removeAnimations(items: [AnimationInfo]) {
        for item in items {
            removeAnimation(forKey: item.key)
        }
    }
    
    func perfrormAnimation(items: [AnimationInfo], timing: CAMediaTimingFunctionName, duration: TimeInterval, fillMode: CAMediaTimingFillMode, changeValuesClosure: () -> (), completion: (() -> ())? = nil) {
        let keys = items.map { $0.key }.joined(separator: "-")
        let group = CAAnimationGroup()
        group.isRemovedOnCompletion = true
        group.animations = []
        group.timingFunction = CAMediaTimingFunction(name: timing)
        group.duration = duration
        group.fillMode = fillMode
        
        for animation in items {
            let selector = Selector(animation.key)
            if responds(to: selector) {
                let newAnimation = CABasicAnimation(keyPath: animation.key)
                newAnimation.fromValue = animation.fromValue
                newAnimation.toValue = animation.toValue
                group.animations?.append(newAnimation)
            }
        }
        
        changeValuesClosure()
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            self?.removeAnimations(items: items)
            completion?()
        }
        add(group, forKey: keys)
        CATransaction.commit()

    }
}

