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
        static let maxSize: CGSize = .init(width: 3000, height: 3000)
    }
    
    private let layer: CALayer = {
        if UIVisualEffectView.canUseFilteredLayer() {
            return (UIVisualEffectView.filteredLayer() ?? CALayer())
        }
        return CALayer()
    }()
    
    private let context: CIContext = CIContext(options: [CIContextOption.outputColorSpace: NSNull()])
    private let gaussianBlurFilter = CIFilter(name: "CIGaussianBlur")
    private let filteredUsed: Bool
    
    init(parent: CALayer, config: SuggestionsConfig, filteredUsed: Bool, tempLayerClosure: (CALayer) -> ()) {
        self.filteredUsed = filteredUsed
        commonInit(parent: parent, config: config)
        tempLayerClosure(layer)
    }
    
    func update(parent: CALayer, config: SuggestionsConfig) {
        commonInit(parent: parent, config: config, update: true)
    }
}

private extension BlurLayer {
    
    func convert(cmage: CIImage) -> CGImage? {
        
        guard let cgImage: CGImage = context.createCGImage(cmage, from: cmage.extent) else { return nil }
        
        let cgBlurRadius = CGFloat(Constant.blurRadius)
        return cgImage.cropping(to: .init(x: cgBlurRadius * 3, y: cgBlurRadius * 3, width: layer.bounds.width * UIScreen.main.scale, height: layer.bounds.height * UIScreen.main.scale))
    }
    
    func renderBackgroundImage(parent: CALayer) -> CGImage? {
        
        parent.isHidden = true
        
        defer {
            parent.isHidden = false
        }
        
        guard let keyWindow: UIView = {
            if #available(iOS 13.0, *) {
                return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
            } else {
                return UIApplication.shared.keyWindow
            }
        }() else {return nil}
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(keyWindow.bounds.size, false, scale);
        guard let _ = UIGraphicsGetCurrentContext() else {return nil}
        keyWindow.drawHierarchy(in: keyWindow.bounds, afterScreenUpdates: false)
        guard let image = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {return nil}
        UIGraphicsEndImageContext()

        let imageToBlur: CIImage? = CIImage(cgImage: image)
        gaussianBlurFilter?.setValue(imageToBlur, forKey: "inputImage")
        gaussianBlurFilter?.setValue(NSNumber(value: Constant.blurRadius), forKey: "inputRadius")
        guard let resultImage = gaussianBlurFilter?.value(forKey: "outputImage") as? CIImage else { return nil }
        
        return convert(cmage: resultImage)
    }
    
    @objc func render() {
        guard let superlayer = layer.superlayer else { return }
        layer.contents = renderBackgroundImage(parent: superlayer)
    }
    
    func commonInit(parent: CALayer, config: SuggestionsConfig, update: Bool = false) {
        layer.isGeometryFlipped = true
        layer.drawsAsynchronously = true
        parent.insertSublayer(layer, at: 1)
        layer.anchorPoint = .init(x: 1.0, y: 1.0)
        if filteredUsed {
            layer.frame = .init(origin: .zero, size: Constant.maxSize)
        } else {
            layer.contentsGravity = .resizeAspectFill
            layer.frame = parent.frame
            render()
        }
        layer.name = String(describing: self)
    }
}
