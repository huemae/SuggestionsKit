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
    
    
    @IBOutlet var allViews: [UIView]!
    var manager: SuggestionsManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        showSuggestions()
    }
    
    func showSuggestions() {
        let subviews = allViews.sorted(by: { $0.frame.origin.y < $1.frame.origin.y })
        let suggestions = subviews.compactMap { ($0, self.textForComponent(view: $0)) }
        manager = SuggestionsManager(with: suggestions, mainView: view, config: nil)
        manager?.startShowing()
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefg hijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func textForComponent(view: UIView) -> String {
        switch view {
            case view as? UITextField:
                return "Сюда вы можете ввести текст"
            case view as? UIStepper:
                return "Можно увеличивать и уменьшать значения"
            case view as? UIButton:
                return "Это кнопка. На нее можно нажимать и получать разный результат!"
            case view as? UISwitch:
                return "Обычный переключатель"
            case view as? UIActivityIndicatorView:
                return "Индикатор загрузки. Нужно подождать..."
            case view as? UIProgressView:
                return "Индикатор прогресса чего угодно."
            default:
                return randomString(length: 44)
        }
    }

}

