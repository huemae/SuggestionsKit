//
//  UIVisualEffectView+Extension.swift
//  SuggestionsKit
//
//  Created by ilyailusha on 06.06.2020.
//  Copyright © 2020 huemae. All rights reserved.
//

import Foundation
import UIKit
import OpenGLES


extension UIVisualEffectView {
    
    static func canUseFilteredLayer() -> Bool {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        
        return false
                
        return !(view.layer.sublayers?.first?.filters?.isEmpty ?? true)
    }
    
    static func filteredLayer() -> CALayer? {
        
        let style: UIBlurEffect = {
            if #available(iOS 10.0, *) {
                return UIBlurEffect(style: .prominent)
            } else {
                return UIBlurEffect(style: .light)
            }
        }()
        
        let view =  UIVisualEffectView(effect: style)
        
        return view.layer.sublayers?.first
    }
}
