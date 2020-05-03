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
    
    private var layer: CAShapeLayer = CAShapeLayer()
    
    init(parent: CALayer, config: SuggestionsConfig, tempLayerClosure: (CALayer) -> ()) {
        commonInit(parent: parent, config: config)
        tempLayerClosure(layer)
    }
    
    func update(parent: CALayer, config: SuggestionsConfig, tempLayerClosure: (CALayer) -> ()) {
        commonInit(parent: parent, config: config)
        tempLayerClosure(layer)
    }
}

private extension BlurLayer {
    
    func convert(cmage: CIImage) -> CGImage? {
        let context: CIContext = CIContext(options: nil)
        guard let cgImage: CGImage = context.createCGImage(cmage, from: cmage.extent) else { return nil }
        
        return cgImage
    }
    
    func renderBackgroundImage(parent: CALayer) -> CGImage? {
        let mainViewLayer = parent.superlayer?.sublayers?.filter { $0 is MainViewLayer }.first
        let hiddenState = mainViewLayer?.isHidden ?? false
        
        defer {
            mainViewLayer?.isHidden = hiddenState
        }
        mainViewLayer?.isHidden = true
        
        UIGraphicsBeginImageContextWithOptions(parent.bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        parent.superlayer?.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else { return nil }
        UIGraphicsEndImageContext()

        let imageToBlur: CIImage? = CIImage(cgImage: image)
        let gaussianBlurFilter = CIFilter(name: "CIGaussianBlur")
        gaussianBlurFilter?.setValue(imageToBlur, forKey: "inputImage")
        gaussianBlurFilter?.setValue(NSNumber(value: 5), forKey: "inputRadius")
        let resultImage = gaussianBlurFilter?.value(forKey: "outputImage") as? CIImage
        
        guard let result = resultImage else { return nil}
        
        return convert(cmage: result)
    }
    
    func commonInit(parent: CALayer, config: SuggestionsConfig) {
        layer.isGeometryFlipped = true
        layer.contents = renderBackgroundImage(parent: parent)
        layer.frame = parent.bounds
        layer.contentsGravity = .resizeAspectFill
        layer.contentsScale = UIScreen.main.scale
        layer.opacity = 1.0
        layer.name = String(describing: self)
        
        parent.insertSublayer(layer, at: 1)
    }
}
