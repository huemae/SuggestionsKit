//
//  TableViewController.swift
//  SuggestionsKit-Example
//
//  Created by huemae on 07.05.2020.
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
import SuggestionsKit


class TableViewController: UITableViewController {
    
    var selectedIndexPath = IndexPath(row: 0, section: 0)
    
    func titleAndConfig(for indexPath: IndexPath) -> (String, SuggestionsConfig) {
        
        switch indexPath.row {
            case 0:
                let config = SuggestionsConfig()
                return ("Default", config)
            case 1:
                let config = SuggestionsConfig(background: SuggestionsConfig.Background(blurred: false))
                return ("Unblurred", config)
            case 2:
                let config = SuggestionsConfig(shouldBounceAfterMove: false)
                return ("Without bounce", config)
            case 3:
                let config = SuggestionsConfig(animationsTimingFunction: .easeInEaseOut)
                return ("Different timing function", config)
            case 4:
                let config = SuggestionsConfig()
                return ("Tab bar items support", config)
            case 5:
                let config = SuggestionsConfig(text: .init(font: UIFont.systemFont(ofSize: 30, weight: .bold)))
                return ("Different fonts", config)
            case 6:
                let config = SuggestionsConfig(buble: .init(shadowColor: .white, shadowRadius: 10, shadowOpacity: 1.0, shadowOffset: .zero), text: .init(textColor: UIColor.darkGray, font: .systemFont(ofSize: 12, weight: .regular)))
                return ("Buble glow", config)
            
            default:
                let config = SuggestionsConfig()
                return ("Default", config)
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? ViewController
        vc?.config = titleAndConfig(for: selectedIndexPath).1
        if selectedIndexPath.row == 4 {
            vc?.tabBarTest = true
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = titleAndConfig(for: indexPath)
        cell.textLabel?.text = item.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndexPath = indexPath
        performSegue(withIdentifier: "showSuggestions", sender: nil)
    }
}
