//
//  SuggestionsBlurLayer.swift
//  Suggestions
//
//  Created by ilyailusha on 09.04.2020.
//  Copyright © 2020 ilyailusha. All rights reserved.
//

import Foundation
import UIKit


class SuggestionsBlurLayer {
    
    private let layer: CAShapeLayer = CAShapeLayer()
    
    init(parent: CALayer, config: SuggestionsConfig, tempLayerClosure: (CALayer) -> ()) {
        commonInit(parent: parent, config: config)
        tempLayerClosure(layer)
    }
}

private extension SuggestionsBlurLayer {
    
    func convert(cmage: CIImage) -> CGImage? {
        let context: CIContext = CIContext(options: nil)
        guard let cgImage: CGImage = context.createCGImage(cmage, from: cmage.extent) else { return nil }
        
        return cgImage
    }
    
    func renderBackgroundImage(parent: CALayer) -> CGImage? {
        UIGraphicsBeginImageContextWithOptions(parent.bounds.size, true, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        parent.superlayer?.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        //Blur the UIImage
        var imageToBlur: CIImage? = nil
        if let CGImage = image?.cgImage {
            imageToBlur = CIImage(cgImage: CGImage)
        }
        let gaussianBlurFilter = CIFilter(name: "CIGaussianBlur")
        gaussianBlurFilter?.setValue(imageToBlur, forKey: "inputImage")
        gaussianBlurFilter?.setValue(NSNumber(value: 5), forKey: "inputRadius") //change number to increase/decrease blur
        let resultImage = gaussianBlurFilter?.value(forKey: "outputImage") as? CIImage

        //create UIImage from filtered image
        if let resultImage = resultImage {
            return convert(cmage: resultImage)
        }
        
        return nil
    }
    
    func commonInit(parent: CALayer, config: SuggestionsConfig) {
        layer.isGeometryFlipped = true
        layer.contents = renderBackgroundImage(parent: parent)
        layer.frame = parent.bounds
        layer.contentsGravity = .resizeAspectFill
        layer.contentsScale = UIScreen.main.scale
        layer.opacity = 1.0
        
        parent.insertSublayer(layer, at: 999)
    }
}
