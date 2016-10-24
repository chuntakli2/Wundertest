//
//  UIColor+Utils.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import UIKit

extension UIColor {
    
    // MARK: - Public Methods
    
    public class func colour(fromHexString hexString: String) -> UIColor {
        let scanner = Scanner(string: hexString)
        var hexNumber: UInt32 = 0
        let success = scanner.scanHexInt32(&hexNumber)
        
        guard (success) else { return .clear }
        if (hexString.characters.count <= 6) {
            return colour(fromRGB: hexNumber)
        } else {
            let rgb = (hexNumber & 0xFFFFFF00) >> 8
            let alpha = 1.0 * CGFloat((hexNumber & 0xFF)) / 255.0 as CGFloat
            return colour(fromRGB: rgb, alpha: alpha)
        }
    }
    
    // MARK: - Private Methods
    
    fileprivate class func colour(fromRGB rgb: UInt32) -> UIColor {
        return colour(fromRGB: rgb, alpha: 1.0)
    }
    
    fileprivate class func colour(fromRGB rgb: UInt32, alpha: CGFloat) -> UIColor {
        return UIColor(red: CGFloat(((rgb & 0xFF0000) >> 16)) / 255.0, green: CGFloat(((rgb & 0xFF00) >> 8)) / 255.0, blue: CGFloat(rgb & 0xFF) / 255.0, alpha: alpha)
    }
}
