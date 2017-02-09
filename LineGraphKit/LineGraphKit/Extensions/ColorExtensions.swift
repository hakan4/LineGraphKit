//
//  ColorExtensions.swift
//  GraphKit
//
//  Created by Håkan Andersson on 20/06/15.
//  Copyright (c) 2015 Fineline. All rights reserved.
//

import Foundation

extension UIColor {
    public class func randomColor(_ alpha: CGFloat = 1) -> UIColor {
        var randomColor : CGFloat {
            return CGFloat(Float(arc4random_uniform(255))/255.0)
        }
        return UIColor(red: randomColor, green: randomColor, blue: randomColor, alpha: alpha)
    }
}
