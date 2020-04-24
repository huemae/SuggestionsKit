//
//  SuggestionsManager.swift
//  Suggestions
//
//  Created by ilyailusha on 01.04.2020.
//  Copyright © 2020 ilyailusha. All rights reserved.
//

import Foundation
import UIKit


final public class SuggestionsManager {
    
    public typealias Suggestion = (view: UIView, text: String)
    
    private var suggestions: [Suggestion]
    
    private var suggestionsOverlay: SuggestionsObject?
    
    
    public init(with suggestions:[Suggestion], mainView: UIView) {
        self.suggestions = suggestions
        start(with: mainView)
    }
    
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
    
    func start(with main: UIView) {
        suggestionsOverlay = SuggestionsObject(with: main, config: nil)
        
        suggestionsOverlay?.viewTappedBlock = { [weak self] in
            self?.suggestions.removeFirst()
            self?.updateSuggestion()
        }
    }
}
