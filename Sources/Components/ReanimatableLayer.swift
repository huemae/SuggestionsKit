//
//  ReanimatableLayer.swift
//  SuggestionsKit
//
//  Created by ilyailusha on 26.06.2020.
//  Copyright © 2020 huemae. All rights reserved.
//

import Foundation
import UIKit


class ReanimatableLayer: CAShapeLayer {
    
    private var tempAnimation: CAAnimation?
    private var tempAnimationKey: String?
    
    override init() {
        super.init()
        commonInit()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        commonInit()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ReanimatableLayer {
    
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
    
    func commonInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(back), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(front), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}
