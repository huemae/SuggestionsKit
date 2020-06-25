//
//  String+Extension.swift
//  SuggestionsKit
//
//  Created by huemae on 25.06.2020.
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


extension String {
    
    static var screenScale = UIScreen.main.scale
    
    func floorToScreenPixels(_ value: CGFloat) -> CGFloat {
        return floor(value * Self.screenScale) / Self.screenScale
    }
    
    func calculateHeight(textFont: UIFont, maxWidth: CGFloat) -> CGSize {
        
        let constrainedSize: CGSize = .init(width: maxWidth, height: .greatestFiniteMagnitude)
        let attributedString = NSAttributedString(string: self, attributes: [NSAttributedString.Key.font: textFont])
        let stringLength = attributedString.length
        
        let font: CTFont
        if stringLength != 0 {
            if let stringFont = attributedString.attribute(NSAttributedString.Key.font, at: 0, effectiveRange: nil) {
                font = stringFont as! CTFont
            } else {
                font = textFont
            }
        } else {
            font = textFont
        }
        let lineSpacingFactor: CGFloat = 0.12
        let maximumNumberOfLines = 0
        let fontAscent = CTFontGetAscent(font)
        let fontDescent = CTFontGetDescent(font)
        let fontLineHeight = floor(fontAscent + fontDescent)
        let fontLineSpacing = floor(fontLineHeight * lineSpacingFactor)
        let truncationType: CTLineTruncationType = .end
        
        var maybeTypesetter: CTTypesetter?
        maybeTypesetter = CTTypesetterCreateWithAttributedString(attributedString as CFAttributedString)
        
        let typesetter = maybeTypesetter!
        var lastLineCharacterIndex: CFIndex = 0
        var layoutSize = CGSize()
        
        var first = true
        var linesCount = 0
        while true {
            let lineConstrainedWidth = constrainedSize.width
            var lineOriginY = floorToScreenPixels(layoutSize.height + fontAscent)
            if !first {
                lineOriginY += fontLineSpacing
            }
            let lineAdditionalWidth: CGFloat = 0.0
            
            let lineCharacterCount = CTTypesetterSuggestLineBreak(typesetter, lastLineCharacterIndex, Double(lineConstrainedWidth))
            
            var isLastLine = false
            if maximumNumberOfLines != 0 && linesCount == maximumNumberOfLines - 1 && lineCharacterCount > 0 {
                isLastLine = true
            } else if layoutSize.height + (fontLineSpacing + fontLineHeight) * 2.0 > constrainedSize.height {
                isLastLine = true
            }
            
            if isLastLine {
                if first {
                    first = false
                } else {
                    layoutSize.height += fontLineSpacing
                }
                
                let lineRange = CFRange(location: lastLineCharacterIndex, length: stringLength - lastLineCharacterIndex)
                
                if lineRange.length == 0 {
                    break
                }
                
                let coreTextLine: CTLine
                
                let originalLine = CTTypesetterCreateLineWithOffset(typesetter, lineRange, 0.0)
                
                if CTLineGetTypographicBounds(originalLine, nil, nil, nil) - CTLineGetTrailingWhitespaceWidth(originalLine) < Double(constrainedSize.width) {
                    coreTextLine = originalLine
                } else {
                    var truncationTokenAttributes: [NSAttributedString.Key : AnyObject] = [:]
                    truncationTokenAttributes[NSAttributedString.Key.font] = font
                    truncationTokenAttributes[NSAttributedString.Key(rawValue:  kCTForegroundColorFromContextAttributeName as String)] = true as NSNumber
                    let tokenString = "\u{2026}"
                    let truncatedTokenString = NSAttributedString(string: tokenString, attributes: truncationTokenAttributes)
                    let truncationToken = CTLineCreateWithAttributedString(truncatedTokenString)
                    
                    coreTextLine = CTLineCreateTruncatedLine(originalLine, Double(constrainedSize.width), truncationType, truncationToken) ?? truncationToken
                }
                
                let lineWidth = min(constrainedSize.width, ceil(CGFloat(CTLineGetTypographicBounds(coreTextLine, nil, nil, nil) - CTLineGetTrailingWhitespaceWidth(coreTextLine))))
                layoutSize.height += fontLineHeight + fontLineSpacing
                layoutSize.width = max(layoutSize.width, lineWidth + lineAdditionalWidth)
                linesCount += 1
                
                break
            } else {
                if lineCharacterCount > 0 {
                    if first {
                        first = false
                    } else {
                        layoutSize.height += fontLineSpacing
                    }
                    
                    let lineRange = CFRangeMake(lastLineCharacterIndex, lineCharacterCount)
                    let coreTextLine = CTTypesetterCreateLineWithOffset(typesetter, lineRange, 100.0)
                    lastLineCharacterIndex += lineCharacterCount
                    
                    let lineWidth = ceil(CGFloat(CTLineGetTypographicBounds(coreTextLine, nil, nil, nil) - CTLineGetTrailingWhitespaceWidth(coreTextLine)))
                    layoutSize.height += fontLineHeight
                    layoutSize.width = max(layoutSize.width, lineWidth + lineAdditionalWidth)
                    linesCount += 1
                } else {
                    if linesCount > 0 {
                        layoutSize.height += fontLineSpacing
                    }
                    break
                }
            }
        }
        
        return CGSize(width: ceil(layoutSize.width), height: ceil(layoutSize.height))
    }
}
