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
