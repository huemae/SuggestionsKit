//
//  SuggestionsObject.swift
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

class SuggestionsObject: NSObject {
    
    enum Constant {
        static let spaceBetweenOverlayAndText: CGFloat = 10.0
        static let bubleOffset: CGFloat = 10.0
        static let minimalCornerRadius: CGFloat = 5.0
        static let holeOverdrawAmount: CGFloat = 10.0
        static let textDrawingSuperviewOffset: CGFloat = 10.0
    }
    
    private var fillLayer: FillLayer?
    private var bubleLayer: BubleLayer?
    private var textLayer: TextLayer?
    private var blurLayer: BlurLayer?
    private var unblurLayer: UnblurLayer?
    private var mainView: MainView?
    private var superview: UIView?
    
    private var lastSuggested: SuggestionsManager.Suggestion?
    private var mainPath: UIBezierPath?
    private var lastHolePath: UIBezierPath?
    
    
    private var holeRect: CGRect = .zero
    private var textLayerRect: CGRect = .zero
    private var holeMoveDuration: TimeInterval = 0
    
    private var config: SuggestionsConfig?
    
    private var view: UIView {
        guard let view = mainView else { preconditionFailure("") }
        
        return view
    }
    
    private var layer: CALayer {
        guard let layer = mainView?.layer else { preconditionFailure("") }
        
        return layer
    }
    
    private var bounds: CGRect {
        guard let view = mainView else { preconditionFailure("") }
        
        return view.bounds
    }
    
    private var frame: CGRect {
        guard let view = mainView else { preconditionFailure("") }
        
        return view.frame
    }
    
    private var insets: UIEdgeInsets {
        guard let view = mainView else { preconditionFailure("") }
        
        if #available(iOS 11.0, *) {
            return view.safeAreaInsets
        } else {
            return UIEdgeInsets.zero
        }
    }
    
    private let defaultConfig: SuggestionsConfig = {
        let buble = SuggestionsConfig.BubleConfig(shouldDraw: true, tailHeight: 5, focusOffset: 5, cornerRadius: 10, borderWidth: 0.5, borderColor: UIColor.clear, backgroundColor: UIColor.black)
        let text = SuggestionsConfig.TextConfig(textColor: UIColor.white, font: UIFont.systemFont(ofSize: 15, weight: .regular))
        let background = SuggestionsConfig.Background(opacity: 0.5, blurred: true, color: UIColor.black)
        
        return SuggestionsConfig(buble: buble, text: text, background: background, animationsTimingFunction: CAMediaTimingFunctionName.linear)
    }()
    
    private var currentConfig: SuggestionsConfig {
        return config ?? defaultConfig
    }
    
    var viewTappedBlock: (() -> ())?
    
    init(with superview: UIView, config: SuggestionsConfig? = nil) {
        super.init()
        configure(with: config, superview: superview)
    }
    
    deinit {
        print("\(String(describing: self)) \(#function)")
    }
    
    func suggestionsFinished() {
        removeObservingAtLastSuggested()
        mainView?.removeFromSuperview()
    }
    
    func updateForSuggestion(suggestion: SuggestionsManager.Suggestion?) {
        if let suggestion = suggestion {
            startObserve(suggestion: suggestion)
            updateWithSuggestion(suggestion: suggestion)
        } else {
            suggestionsFinished()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let suggestion = lastSuggested else { return }
        updateForSuggestion(suggestion: suggestion)
        blurLayer?.update(parent: layer, config: currentConfig, tempLayerClosure: { (layer) in

        })
        unblurLayer?.updateUnblur(suggestion: suggestion, holeRect: holeRect, animationDuration: holeMoveDuration)
    }
}

private extension SuggestionsObject {
    
    func startObserve(suggestion: SuggestionsManager.Suggestion) {
        removeObservingAtLastSuggested()
        lastSuggested = suggestion
        lastSuggested?.view.addObserver(self, forKeyPath: #keyPath(UIView.center), options: [.new], context: nil)
    }
    
    func removeObservingAtLastSuggested() {
        lastSuggested?.view.removeObserver(self, forKeyPath: #keyPath(UIView.center))
    }
    
    func frame(of suggestion: SuggestionsManager.Suggestion) -> CGRect {
        guard let superview = mainView?.superview else { return .zero }
        if mainView?.superview?.subviews.contains(suggestion.view) ?? false {
            return suggestion.view.frame
        } else {
            let newOrigin = suggestion.view.convert(superview.frame, to: nil).origin
            return CGRect(x: newOrigin.x, y: newOrigin.y, width: suggestion.view.frame.width, height: suggestion.view.frame.height)
        }
    }
    
    func maxWidthToDrawText() -> CGFloat {
        let bounds = boundsForDrawingText()
        return bounds.width - bounds.origin.x * 2
    }
    
    func boundsForDrawingText() -> CGRect {
        let offset = Constant.textDrawingSuperviewOffset
        if #available(iOS 11.0, *) {
            return frame.inset(by: UIEdgeInsets(top: insets.top + offset, left: insets.left + offset, bottom: insets.bottom + offset, right: insets.right + offset))
        } else {
            return frame.inset(by: UIEdgeInsets(top: offset, left:offset, bottom:offset, right: offset))
        }
    }
    
    func updateText(suggestion: SuggestionsManager.Suggestion) {
        textLayer?.update(boundsForDrawing: boundsForDrawingText(), maxTextWidth: maxWidthToDrawText(), suggestion: suggestion, animationDuration: holeMoveDuration)
    }
    
    func updateOverlay(suggestion: SuggestionsManager.Suggestion) {
        fillLayer?.update(suggestion: suggestion)
    }
    
    func updateBuble(of suggestion: SuggestionsManager.Suggestion) {
        bubleLayer?.update(textRect: textLayerRect, holeRect: holeRect, suggestion: suggestion, animationDuration: holeMoveDuration)
    }
    
    func updateUnblur(suggestion: SuggestionsManager.Suggestion) {
        unblurLayer?.updateUnblur(suggestion: suggestion, holeRect: holeRect, animationDuration: holeMoveDuration)
    }
    
    func updateWithSuggestion(suggestion: SuggestionsManager.Suggestion) {
        updateOverlay(suggestion: suggestion)
        updateText(suggestion: suggestion)
        updateBuble(of: suggestion)
        updateUnblur(suggestion: suggestion)
    }
    
    @objc func viewTapped() {
        viewTappedBlock?()
    }
    
    func configureGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }
    
    func configureAppearance() {
        view.backgroundColor = UIColor.clear
    }
    
    func configreDimmLayer(config: SuggestionsConfig) {
        
        let dimm = FillLayer(parent: layer, config: config)
        dimm.holeMoveDurationUpdatedClosue = { [weak self] duration in
            self?.holeMoveDuration = duration
        }
        
        dimm.holeRectUpdatedClosue = { [weak self] newRect in
            self?.holeRect = newRect
        }
        
        dimm.suggestionFrameClosue = { [weak self] suggestion in
            return self?.frame(of: suggestion) ?? .zero
        }
        
        fillLayer = dimm
    }
    
    func configureBubleLayer(config: SuggestionsConfig) -> CALayer? {
        guard currentConfig.buble.shouldDraw else { return nil }
        var tempLayer: CALayer?
        let buble = BubleLayer(parent: layer, config: config, tempLayerClosure: { layer in
            tempLayer = layer
        })
        bubleLayer = buble
        
        return tempLayer
    }
    
    func configureTextLayer(superLayer: CALayer?, config: SuggestionsConfig) {
        let bubleLayer = superLayer ?? layer
        let textLayer = TextLayer(parent: bubleLayer, config: config)
        textLayer.suggestionFrameClosue = { [weak self] suggestion in
            return self?.frame(of: suggestion) ?? .zero
        }
        textLayer.textLayerUpdatedFrameClosue = { [weak self] newTextFrame in
            self?.textLayerRect = newTextFrame
        }
        
        self.textLayer = textLayer
    }
    
    func configureUnblurLayer(with blur: CALayer?, config: SuggestionsConfig) {
        guard let superBlur = blur else { return }
        unblurLayer = UnblurLayer(maskedLayer: superBlur, superBunds: bounds)
    }
    
    func configureBlurLayer(config: SuggestionsConfig) -> CALayer? {
        guard config.background.blurred else { return nil }
        var newLayer: CALayer?
        blurLayer = BlurLayer(parent: layer, config: config, tempLayerClosure: { layer in
            newLayer = layer
        })
        
        return newLayer
    }
    
    func configureSublayers(config: SuggestionsConfig) {
        let newLayer = configureBlurLayer(config: config)
        configureUnblurLayer(with: newLayer, config: config)
        configreDimmLayer(config: config)
        let temp = configureBubleLayer(config: config)
        configureTextLayer(superLayer: temp, config: config)
    }
    
    func configureMainView(superview: UIView) {
        self.superview = superview
        let main = MainView(parent: superview)
        mainView = main
    }
    
    func configure(with config: SuggestionsConfig?, superview: UIView) {
        self.config = config
        configureMainView(superview: superview)
        configureGestures()
        configureAppearance()
        configureSublayers(config: currentConfig)
    }
}
