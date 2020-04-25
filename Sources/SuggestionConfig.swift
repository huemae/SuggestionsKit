//
//  SuggestionConfig.swift
//  SuggestionsKit
//
//  Created by ilyailusha on 25.04.2020.
//

import Foundation
import UIKit


public struct SuggestionsConfig {
    
    struct BubleConfig {
        let shouldDraw: Bool
        let tailHeight: CGFloat
        let focusOffset: CGFloat
        let cornerRadius: CGFloat
        let borderWidth: CGFloat
        let borderColor: UIColor
        let backgroundColor: UIColor
    }
    
    struct TextConfig {
        let textColor: UIColor
        let font: UIFont
    }
    
    struct Background {
        let opacity: CGFloat
        let blurred: Bool
        let color: UIColor
    }
    
    let buble: BubleConfig
    let text: TextConfig
    let background: Background
    let animationsTimingFunction: CAMediaTimingFunctionName
}
