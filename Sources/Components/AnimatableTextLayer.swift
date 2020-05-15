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
    
    func updateNextAnimationDuration(duration: TimeInterval) {
        animationDuration = duration
    }
    
    
    override func add(_ anim: CAAnimation, forKey key: String?) {
        super.add(anim, forKey: key)
    }
    
    override func action(forKey event: String) -> CAAction? {
        let curAnim = super.action(forKey: event) as? CAAnimation
        guard let anim = curAnim?.mutableCopy() as? CAAnimation else { return nil }
        anim.timingFunction = CAMediaTimingFunction(name: config.animationsTimingFunction)
        anim.duration = animationDuration
        anim.fillMode = .forwards
        
        return anim
    }
}
