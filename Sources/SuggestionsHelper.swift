//
//  SuggestionsHelper.swift
//  SuggestionsKit
//
//  Created by huemae on 05.05.2020.
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



public final class SuggestionsHelper {
    
    public enum SearchType {
        case byText(String)
        case byTag(Int)
        case classNameContains(String)
        case hitable
    }
    
    public class SearchViewParameters: NSObject {
        let type: AnyObject.Type
        let search: SearchType
        
        public init(type: AnyObject.Type, search: SearchType) {
            self.type = type
            self.search = search
        }
    }
    
    public static func findViewRecursively(in view: UIView?, parameters: SearchViewParameters) -> UIView? {
        guard let mainView = view else { return nil }
        
        switch parameters.type {
            case is UILabel.Type:
                if let label = mainView as? UILabel {
                    switch parameters.search {
                        case .byTag(let tag):
                            return label.tag == tag ? label : nil
                        case .byText(let text):
                            if label.text == text {
                                return label
                            }
                            break
                        case .classNameContains(let className):
                            if String(NSStringFromClass(label.classForCoder)).contains(className) {
                                return label
                            }
                            break
                        case .hitable:
                            if label.hitTest(.zero, with: nil) == label {
                                return label
                            }
                            break
                    }
            }
            case is UIButton.Type:
                if let button = mainView as? UIButton {
                    switch parameters.search {
                        case .byTag(let tag):
                            return button.tag == tag ? button : nil
                        case .byText(let text):
                            return button.titleLabel?.text == text ? button : nil
                        case .classNameContains(let className):
                            if String(NSStringFromClass(button.classForCoder)).contains(className) {
                                return button
                            }
                            break
                        case .hitable:
                            if button.hitTest(.zero, with: nil) == button {
                                return button
                            }
                            break
                    }
            }
            default:
                break
        }
        
        return mainView.subviews.compactMap { findViewRecursively(in: $0, parameters: parameters) }.first
    }
    
    static public func findAllBarItems(in view: UIView?, captured: [UIView] = []) -> [UIView] {
        guard let mainView = view else { return captured }
        
        var newCaptured = Set(captured)
        
        for view in mainView.subviews {
            for finded in findAllBarItems(in: view, captured: Array(newCaptured)) where finded.isKind(of: UIControl.self) {
                newCaptured.insert(finded)
            }
            if view.isKind(of: UIControl.self) {
                newCaptured.insert(view)
            }
        }
        
        return Array(newCaptured)
            .filter { $0.isUserInteractionEnabled }
            .sorted(by: {
                guard let superFirst = $0.superview, let superSecond = $1.superview else { return true }
                let root = UIApplication.shared.keyWindow
                let leftX = superFirst.convert($0.frame, to: root).origin.x
                let rightX = superSecond.convert($1.frame, to: root).origin.x
                
                return leftX < rightX
            })
    }
    
    
}
