//
//  ViewController.swift
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

import UIKit
import SuggestionsKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var winkButton: UIButton!
    @IBOutlet weak var blockUser: UIButton!
    
    
    var titleText: String = ""
    var tabBarTest: Bool = false
    var config: SuggestionsConfig = SuggestionsConfig()
    

    override func viewDidAppear(_ animated: Bool) {
         showSuggestions()
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        showSuggestions()
    }
	
	func createButtonSuggestions() -> [Suggestion] {
		let sendSuggestion = Suggestion(view: sendMessageButton, text: "Tap here to send message to user")
		let shareSuggestion = Suggestion(view: shareButton, text: "Tap here to share users profile")
		let infoSuggestion = Suggestion(view: infoLabel, text: "Small info about user")
		let winkSuggestion = Suggestion(view: winkButton, text: "You also can wink to show what you are interested in a person")
		let blockSuggestion = Suggestion(view: blockUser, text: "Or block the user if he is obsessive")
		
		return [sendSuggestion, shareSuggestion, infoSuggestion, winkSuggestion, blockSuggestion]
	}
	
	func createNavigationSuggestions() -> [Suggestion] {
		var suggestions: [Suggestion] = []
		
		if let titleLabel = SuggestionsHelper.findViewRecursively(in: navigationController?.navigationBar, parameters: SuggestionsHelper.SearchViewParameters(type: UILabel.self, search: .byText("Example"))) {
			let suggestion = Suggestion.init(view: titleLabel, text: "Title support!")
			suggestions += [suggestion]
		}
		let navItems = SuggestionsHelper.findAllBarItems(in: navigationController?.navigationBar)
		let navSuggestions = navItems.enumerated()
			.map { Suggestion(view: $0.element, text: $0.offset == 0 ? "back button" : "bar button item") }
		
		return suggestions + navSuggestions
	}
	
	func createFrameSuggestions() -> [Suggestion] {
		let exampleAttrString1 = NSAttributedString(string: "frame suggestion #1",
												   attributes: [.font: UIFont.systemFont(ofSize: 25, weight: .thin),
																.foregroundColor: UIColor.lightGray])
		let exampleAttrString2 = NSAttributedString(string: "frame suggestion #2",
												   attributes: [.font: UIFont.systemFont(ofSize: 25, weight: .thin),
																.foregroundColor: UIColor.lightGray])
		let frameSuggestion1 = Suggestion(frame: .init(x: 100, y: 0, width: view.frame.width - 200, height: view.frame.height / 2), attributedText: exampleAttrString1)
		let frameSuggestion2 = Suggestion(frame: .init(x: 100, y: view.frame.height / 2, width: view.frame.width - 200, height: view.frame.height / 2), attributedText: exampleAttrString2)
		
		
		let paragraphStyleLeftAlign = NSMutableParagraphStyle()
		paragraphStyleLeftAlign.alignment = .left

		let exampleAttrString3 = NSAttributedString(string: "frame suggestion #1 The quick brown fox jumps over the lazy dog, long text to test left align\nidea proposed by @viralsavaniIM",
													attributes: [.font: UIFont.systemFont(ofSize: 25, weight: .thin),
																.foregroundColor: UIColor.lightGray,
																.paragraphStyle: paragraphStyleLeftAlign])
		let alignmentLeftSuggestion = Suggestion(
			frame: .init(x: 200, y: view.frame.height / 2, width: view.frame.width - 200, height: view.frame.height / 2),
			attributedText: exampleAttrString3)
		
		return [frameSuggestion1, frameSuggestion2, alignmentLeftSuggestion]
	}
    
    func showSuggestions() {
        var suggestions: [Suggestion] = []
        if tabBarTest {
            let tabBarItems = SuggestionsHelper.findAllBarItems(in: tabBarController?.tabBar)
            suggestions += tabBarItems.enumerated()
                .map { Suggestion(view: $0.element, text: "Tab bar item \($0.offset)") }
        } else {
            
            let buttonSuggestions = createButtonSuggestions()
			let navigationSuggestions = createNavigationSuggestions()
            let frameSuggestions = createFrameSuggestions()
			
			suggestions = buttonSuggestions + navigationSuggestions + frameSuggestions
        }
        
        
		SuggestionsManager.apply(suggestions)
            .configre(config)
            .startShowing()
            .completion {
                print("suggestions finished")
            }
    }
}
