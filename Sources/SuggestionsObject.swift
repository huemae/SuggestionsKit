//
//  SuggestionsObject.swift
//  Suggestions
//
//  Created by ilyailusha on 01.04.2020.
//  Copyright © 2020 ilyailusha. All rights reserved.
//

import Foundation
import UIKit

class SuggestionsObject {
    
    struct Config {
        
        struct BubleConfig {
            let shouldDraw: Bool
            let tailHeight: CGFloat
            let focusOffset: CGFloat
            let cornerRadius: CGFloat
            let borderWidth: CGFloat
            let borderColor: UIColor
            let backgroundColor: UIColor
        }
        
        struct TextConfig {
            let textColor: UIColor
            let font: UIFont
        }
        
        struct Background {
            let opacity: CGFloat
            let blurred: Bool
            let color: UIColor
        }

        let buble: BubleConfig
        let text: TextConfig
        let background: Background
        let animationsTimingFunction: CAMediaTimingFunctionName
    }
    
    enum Constant {
        static let spaceBetweenOverlayAndText: CGFloat = 10.0
        static let bubleOffset: CGFloat = 10.0
        static let minimalCornerRadius: CGFloat = 5.0
        static let holeOverdrawAmount: CGFloat = 10.0
        static let textDrawingSuperviewOffset: CGFloat = 10.0
    }
    
    private var fillLayer: SuggestionsFillLayer?
    private var bubleLayer: SuggestionsBubleLayer?
    private var textLayer: SuggestionsTextLayer?
    private var blurLayer: SuggestionsBlurLayer?
    private var unblurLayer: SuggestionsUnblurLayer?
    private var mainView: UIView?
    private var superview: UIView!
    
    private var mainPath: UIBezierPath?
    private var lastHolePath: UIBezierPath?
    
    
    private var holeRect: CGRect = .zero
    private var textLayerRect: CGRect = .zero
    private var holeMoveDuration: TimeInterval = 0
    
    private var config: Config?
    
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
    
    private let defaultConfig: Config = {
        let buble = Config.BubleConfig(shouldDraw: true, tailHeight: 5, focusOffset: 5, cornerRadius: 10, borderWidth: 0.5, borderColor: UIColor.clear, backgroundColor: UIColor.black)
        let text = Config.TextConfig(textColor: UIColor.white, font: UIFont.systemFont(ofSize: 15, weight: .thin))
        let background = Config.Background(opacity: 0.5, blurred: true, color: UIColor.black)
        
        return Config(buble: buble, text: text, background: background, animationsTimingFunction: CAMediaTimingFunctionName.linear)
    }()
    
    private var currentConfig: Config {
        return config ?? defaultConfig
    }
    
    var viewTappedBlock: (() -> ())?
    
    init(with superview: UIView, config: Config? = nil) {
        configure(with: config, superview: superview)
    }
    
    deinit {
        print("\(String(describing: self)) \(#function)")
    }
    
    func suggestionsFinished() {
        mainView?.removeFromSuperview()
    }
    
    func updateForSuggestion(suggestion: SuggestionsManager.Suggestion?) {
        if let suggestion = suggestion {
            updateWithSuggestion(suggestion: suggestion)
        } else {
            suggestionsFinished()
        }
    }
}

private extension SuggestionsObject {
    
    func frame(of suggestion: SuggestionsManager.Suggestion) -> CGRect {
        guard let superview = mainView?.superview else { return .zero }
        let newOrigin = suggestion.view.convert(superview.frame, to: nil).origin
        return CGRect(x: newOrigin.x, y: newOrigin.y, width: suggestion.view.frame.width, height: suggestion.view.frame.height)
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
    
    func configreDimmLayer(config: Config) {
        
        let dimm = SuggestionsFillLayer(parent: layer, config: config)
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
    
    func configureBubleLayer(config: Config) -> CALayer? {
        guard currentConfig.buble.shouldDraw else { return nil }
        var tempLayer: CALayer?
        let buble = SuggestionsBubleLayer(parent: layer, config: config, tempLayerClosure: { layer in
            tempLayer = layer
        })
        bubleLayer = buble
        
        return tempLayer
    }
    
    func configureTextLayer(superLayer: CALayer?, config: Config) {
        let bubleLayer = superLayer ?? layer
        let textLayer = SuggestionsTextLayer(parent: bubleLayer, config: config)
        textLayer.suggestionFrameClosue = { [weak self] suggestion in
            return self?.frame(of: suggestion) ?? .zero
        }
        textLayer.textLayerUpdatedFrameClosue = { [weak self] newTextFrame in
            self?.textLayerRect = newTextFrame
        }
        
        self.textLayer = textLayer
    }
    
    func configureUnblurLayer(with blur: CALayer?, config: Config) {
        guard let superBlur = blur else { return }
        unblurLayer = SuggestionsUnblurLayer(maskedLayer: superBlur, superBunds: bounds)
    }
    
    func configureBlurLayer(config: Config) -> CALayer? {
        guard config.background.blurred else { return nil }
        var newLayer: CALayer?
        blurLayer = SuggestionsBlurLayer(parent: layer, config: config, tempLayerClosure: { layer in
            newLayer = layer
        })
        
        return newLayer
    }
    
    func configureSublayers(config: Config) {
        let newLayer = configureBlurLayer(config: config)
        configureUnblurLayer(with: newLayer, config: config)
        configreDimmLayer(config: config)
        let temp = configureBubleLayer(config: config)
        configureTextLayer(superLayer: temp, config: config)
    }
    
    func configureMainView(superview: UIView) {
        self.superview = superview
        let main = UIView(frame: superview.bounds)
        superview.insertSubview(main, at: Int.max)
        mainView = main
    }
    
    func configure(with config: Config?, superview: UIView) {
        self.config = config
        configureMainView(superview: superview)
        configureGestures()
        configureAppearance()
        configureSublayers(config: currentConfig)
    }
}
