//
//  SuggestionConfig.swift
//  SuggestionsKit
//
//  Created by ilyailusha on 25.04.2020.
//

import Foundation
import UIKit


/// Configuration that will be applied to all suggestions shown by this manager
public struct SuggestionsConfig {
    
    /// Configuration of buble
    struct BubleConfig {
        /// If this property changed to false buble of suggestion will not be shown at all
        let shouldDraw: Bool
        /// Distance between body of buble and top
        let tailHeight: CGFloat
        /// Space between buble tail and suggested view
        let focusOffset: CGFloat
        /// Buble corner radius
        let cornerRadius: CGFloat
        /// Buble border width
        let borderWidth: CGFloat
        /// Buble border color
        let borderColor: UIColor
        /// Buble background color
        let backgroundColor: UIColor
    }
    
    /// Configuration of displayed text
    struct TextConfig {
        /// Color of suggestion's text
        let textColor: UIColor
        /// Font of suggestion's text
        let font: UIFont
    }
    
    /// Configuration of background added above 'mainView'
    struct Background {
        /// Opacity of background
        let opacity: CGFloat
        /// If this property changed to false background will not be blurred
        let blurred: Bool
        /// Color of background
        let color: UIColor
    }
    
    let buble: BubleConfig
    let text: TextConfig
    let background: Background
    /// Animation timing function
    let animationsTimingFunction: CAMediaTimingFunctionName
}
