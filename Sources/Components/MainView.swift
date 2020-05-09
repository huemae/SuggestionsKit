//
//  MainView.swift
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

import Foundation
import UIKit


class MainView: UIView {
    
    var mainViewResizedBlock: ((CGRect) -> Void)?
    
    private var lastFrame: CGRect = .zero
    
    override class var layerClass: AnyClass {
        return MainViewLayer.self
    }
    
    init(parent: UIView) {
        super.init(frame: parent.bounds)
        commonInit(parent: parent)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if lastFrame != frame {
            mainViewResizedBlock?(frame)
            lastFrame = frame
        }
    }
    
    func finish() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0.0
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.removeFromSuperview()
        }
    }
}

private extension MainView {
    
    func configureConstraints(parent: UIView) {
        
        topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: parent.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
    }
    
    func commonInit(parent: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        parent.insertSubview(self, at: Int.max)
        configureConstraints(parent: parent)
    }
}
