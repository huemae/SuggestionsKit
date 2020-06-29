//
//  SuggestionConfig.swift
//  SuggestionsKit
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


/// Configuration that will be applied to all suggestions shown by this manager
public struct SuggestionsConfig {
    
    public enum PreferredTextAppearance {
        case under
        case above
    }
    
    /// Configuration of buble
    public struct BubleConfig {
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
        /// Buble shadow color
        let shadowColor: UIColor
        /// Buble shadow radius
        let shadowRadius: CGFloat
        /// Buble shadow opacity
        let shadowOpacity: CGFloat
        /// Buble shadow offset
        let shadowOffset: CGSize
        
        public init(shouldDraw: Bool = true, tailHeight: CGFloat = 4, focusOffset: CGFloat = 4, cornerRadius: CGFloat = 10, borderWidth: CGFloat = 0.5, borderColor: UIColor = UIColor.clear, backgroundColor: UIColor = UIColor.white, shadowColor: UIColor = UIColor.black, shadowRadius: CGFloat = 10, shadowOpacity: CGFloat = 0.5, shadowOffset: CGSize = CGSize(width: 1, height: 1)) {
            self.shouldDraw = shouldDraw
            self.tailHeight = tailHeight
            self.focusOffset = focusOffset
            self.cornerRadius = cornerRadius
            self.borderWidth = borderWidth
            self.borderColor = borderColor
            self.backgroundColor = backgroundColor
            self.shadowColor = shadowColor
            self.shadowRadius = shadowRadius
            self.shadowOpacity = shadowOpacity
            self.shadowOffset = shadowOffset
        }
    }
    
    /// Configuration of displayed text
    public struct TextConfig {
        /// Color of suggestion's text
        let textColor: UIColor
        /// Font of suggestion's text
        let font: UIFont
        /// Offset between text and hole
        let holeOffset: CGFloat
        
        public init(textColor: UIColor = UIColor.black, font: UIFont = UIFont.systemFont(ofSize: 14), holeOffset: CGFloat = 8) {
            self.textColor = textColor
            self.font = font
            self.holeOffset = holeOffset
        }
    }
    
    /// Configuration of background added above all suggestions
    public struct Background {
        /// Opacity of background
        let opacity: CGFloat
        /// If this property changed to false background will not be blurred
        let blurred: Bool
        /// Color of background
        let color: UIColor
        
        public init(opacity: CGFloat = 0.5, blurred: Bool = true, color: UIColor = UIColor.black) {
            self.opacity = opacity
            self.blurred = blurred
            self.color = color
        }
    }
    
    let buble: BubleConfig
    let text: TextConfig
    let background: Background
    /// Animation timing function
    let animationsTimingFunction: CAMediaTimingFunctionName
    /// Preferred text appearance. Text will appear under suggestion item if set this property to 'under'
    let preferredTextAppearance: PreferredTextAppearance
    /// If true text and buble will bounce around suggestion item
    let shouldBounceAfterMove: Bool
    /// If true will be haptic feedback after passing to next suggestions and after finishing
    let hapticEnabled: Bool
    
    public init(buble: BubleConfig = BubleConfig(), text: TextConfig = TextConfig(), background: Background = Background(), animationsTimingFunction: CAMediaTimingFunctionName = .default, preferredTextAppearance: PreferredTextAppearance = .under, shouldBounceAfterMove: Bool = true, hapticEnabled: Bool = true) {
        self.buble = buble
        self.text = text
        self.background = background
        self.animationsTimingFunction = animationsTimingFunction
        self.preferredTextAppearance = preferredTextAppearance
        self.shouldBounceAfterMove = shouldBounceAfterMove
        self.hapticEnabled = hapticEnabled
    }
}
