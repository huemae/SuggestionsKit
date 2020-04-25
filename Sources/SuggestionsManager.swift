//
//  SuggestionsManager.swift
//  Suggestions
//
//  Created by ilyailusha on 01.04.2020.
//  Copyright © 2020 ilyailusha. All rights reserved.
//

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
        guard let window = main.window else { return }
        suggestionsOverlay = SuggestionsObject(with: window, config: config)
        
        suggestionsOverlay?.viewTappedBlock = { [weak self] in
            self?.suggestions.removeFirst()
            self?.updateSuggestion()
        }
    }
}
