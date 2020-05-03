//
//  SuggestionsManager.swift
//  Suggestions
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


/// Manager that present interface to show suggestions
final public class SuggestionsManager {
    
    public typealias Suggestion = (view: UIView, text: String)
    
    private var suggestions: [Suggestion]
    
    private var suggestionsOverlay: SuggestionsObject?
    
    
    /// This method presents initialization for SuggestionsManager
    /// - Parameters:
    ///   - suggestions: Array of suggestions that you want to show to the user
    ///   - mainView: View that contains suggestions
    ///   - config: Configuration that will be applied to all suggestions shown by this manager
    public init(with suggestions: [Suggestion], mainView: UIView, config: SuggestionsConfig?) {
        self.suggestions = suggestions
        start(with: mainView, config: config)
    }
    
    /// Call this method to start presentation of suggestions
    public func startShowing() {
        updateSuggestion()
    }
    
    deinit {
        print("\(String(describing: self)) \(#function)")
    }
}

private extension SuggestionsManager {
    
    func updateSuggestion() {
        guard let sug = suggestions.first else {
            suggestionsOverlay?.updateForSuggestion(suggestion: nil)
            suggestionsOverlay = nil
            return
        }
        suggestionsOverlay?.updateForSuggestion(suggestion: sug)
    }
    
    func start(with main: UIView, config: SuggestionsConfig?) {
        suggestionsOverlay = SuggestionsObject(with: main, config: config)
        
        suggestionsOverlay?.viewTappedBlock = { [weak self] in
            self?.suggestions.removeFirst()
            self?.updateSuggestion()
        }
    }
}
