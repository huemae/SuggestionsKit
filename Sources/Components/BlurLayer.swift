//
//  BlurLayer.swift
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


class BlurLayer {
    
    private enum Constant {
        static let blurRadius: Float = 5
    }
    
    private var layer: CAShapeLayer = CAShapeLayer()
    
    init(parent: CALayer, config: SuggestionsConfig, tempLayerClosure: (CALayer) -> ()) {
        commonInit(parent: parent, config: config)
        tempLayerClosure(layer)
    }
    
    func update(parent: CALayer, config: SuggestionsConfig) {
        commonInit(parent: parent, config: config, update: true)
    }
}

private extension BlurLayer {
    
    func convert(cmage: CIImage) -> CGImage? {
        let context: CIContext = CIContext(options: nil)
        guard let cgImage: CGImage = context.createCGImage(cmage, from: cmage.extent) else { return nil }
        
        let cgBlurRadius = CGFloat(Constant.blurRadius)
        return cgImage.cropping(to: .init(x: cgBlurRadius * 3, y: cgBlurRadius * 3, width: layer.bounds.width * UIScreen.main.scale, height: layer.bounds.height * UIScreen.main.scale ))
    }
    
    func renderBackgroundImage(parent: CALayer) -> CGImage? {
        let hiddenState = parent.isHidden
        
        defer {
            parent.isHidden = hiddenState
        }
        parent.isHidden = true
        
        guard let image = UIApplication.shared.keyWindow?.snapshot()?.cgImage else { return nil }

        let imageToBlur: CIImage? = CIImage(cgImage: image)
        let gaussianBlurFilter = CIFilter(name: "CIGaussianBlur")
        gaussianBlurFilter?.setValue(imageToBlur, forKey: "inputImage")
        gaussianBlurFilter?.setValue(NSNumber(value: Constant.blurRadius), forKey: "inputRadius")
        guard let resultImage = gaussianBlurFilter?.value(forKey: "outputImage") as? CIImage else { return nil }
        
        return convert(cmage: resultImage)
    }
    
    func commonInit(parent: CALayer, config: SuggestionsConfig, update: Bool = false) {
        layer.isGeometryFlipped = true
        layer.contents = nil
        OperationQueue.main.cancelAllOperations()
        OperationQueue.main.addOperation { [weak self] in
            guard let strongSelf = self else { return }
            let rendered = strongSelf.renderBackgroundImage(parent: parent)
            strongSelf.layer.opacity = 0.0
            strongSelf.layer.contents = rendered
            let animations = [AnimationInfo(key: "opacity", fromValue: 0, toValue: 1)]
            strongSelf.layer.perfrormAnimation(items: animations, timing: config.animationsTimingFunction, duration: 0.2, fillMode: .forwards, changeValuesClosure: {
                strongSelf.layer.opacity = 1.0
            })
        }
        layer.frame = parent.bounds
        layer.contentsGravity = .resizeAspectFill
        layer.contentsScale = UIScreen.main.scale
        layer.opacity = 1.0
        layer.name = String(describing: self)
        
        parent.insertSublayer(layer, at: 1)
    }
}



