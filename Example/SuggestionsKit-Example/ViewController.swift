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
    
    func showSuggestions() {
        var suggestions: [Suggestion] = []
        if tabBarTest {
            let bottomSuggestions = SuggestionsHelper.createSuggestionsFromBarItems(items: tabBarController?.tabBar.items) { index in
                return "Also supports tab bar items \(index)"
            }
            suggestions = bottomSuggestions
        } else {
            let rightSuggestions = SuggestionsHelper.createSuggestionsFromBarItems(items: navigationItem.rightBarButtonItems) { index in
                return "Tap here to restart suggestions\n(navigation items support)"
            }
            let sendSuggestion = Suggestion(view: sendMessageButton, text: "Tap here to send message to user")
            let shareSuggestion = Suggestion(view: shareButton, text: "Tap here to share users profile")
            let infoSuggestion = Suggestion(view: infoLabel, text: "Small info about user")
            let winkSuggestion = Suggestion(view: winkButton, text: "You also can wink to show what you are interested in a person")
            let blockSuggestion = Suggestion(view: blockUser, text: "Or block the user if he is obsessive")
            
            suggestions = rightSuggestions + [sendSuggestion, shareSuggestion, infoSuggestion, winkSuggestion, blockSuggestion]
        }
        
        SuggestionsManager.apply(suggestions)
            .configre(config)
            .startShowing()
            .completion {
                print("suggestions finished")
            }
    }
}
