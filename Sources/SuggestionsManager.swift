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
    
    public typealias VoidBlock = () -> ()
    
    private static let shared = SuggestionsManager()
    
    private var suggestions: [Suggestion] = []
    private var suggestionsOverlay: SuggestionsObject?
    private var completionBlock: VoidBlock?
    
    private init() { }

    /// This method presents configuration for SuggestionsManager
    /// - Parameters:
    ///   - suggestions: Array of suggestions that you want to show to the user
    ///   - config: Configuration that will be applied to all suggestions shown by this manager
    public static func apply(_ suggestions: [Suggestion]) -> SuggestionsManager.Type {
        shared.suggestionsOverlay?.suggestionsFinished()
        shared.suggestions = suggestions.filter { $0.view.superview != nil }
        
        return SuggestionsManager.self
    }
    
    public static func configre(_ config: SuggestionsConfig = SuggestionsConfig()) -> SuggestionsManager.Type {
        shared.start(config: config)
        
        return SuggestionsManager.self
    }
    
    /// Call this method to start presentation of suggestions
    @discardableResult
    public static func startShowing() -> SuggestionsManager.Type {
        shared.updateSuggestion()
        
        return SuggestionsManager.self
    }
    
    /// Call this method to set completion block that will be called after all suggestion showing
    public static func completion(block: @escaping VoidBlock) {
        setCompletion(block: block)
    }
    
    /// Call this method to stop presentation of suggestions
    public static func stopShowing() {
        shared.suggestions = []
        shared.updateSuggestion()
    }
}

private extension SuggestionsManager {
    
    static func setCompletion(block: @escaping VoidBlock) {
        shared.completionBlock = block
    }
    
    func updateSuggestion() {
        guard let sug = suggestions.first else {
            suggestionsOverlay?.updateForSuggestion(suggestion: nil)
            suggestionsOverlay?.suggestionsFinished()
            suggestionsOverlay = nil
            completionBlock?()
            completionBlock = nil
            return
        }
        suggestionsOverlay?.updateForSuggestion(suggestion: sug)
    }
    
    func start(config: SuggestionsConfig) {
        suggestionsOverlay = SuggestionsObject(config: config)
        
        suggestionsOverlay?.viewTappedBlock = { [weak self] in
            guard let strongSelf = self else { return }
            if !strongSelf.suggestions.isEmpty {
                strongSelf.suggestions.removeFirst()
                strongSelf.updateSuggestion()
            }
        }
    }
}
