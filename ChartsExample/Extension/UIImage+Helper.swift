//
//  UIImage+Helper.swift
//  ChartsExample
//
//  Created by Vincent Ngo on 10/27/17.
//  Copyright © 2017 Vincent Ngo. All rights reserved.
//

import UIKit

extension UIImage {
    func image(alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
