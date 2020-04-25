//
//  ViewController.swift
//  SuggestionsKit
//
//  Created by huemae on 04/23/2020.
//  Copyright (c) 2020 huemae. All rights reserved.
//

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

