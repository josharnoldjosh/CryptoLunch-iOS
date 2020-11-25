//
//  Style.swift
//  CryptoLunch
//
//  Created by Josh Arnold on 11/13/20.
//

import Foundation
import UIKit


extension UIColor {
    static var primary: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in                
                return traits.userInterfaceStyle == .dark ?
                    UIColor(red: 43/255, green: 240/255, blue: 151/255, alpha: 1) :
                    UIColor(red: 38/255, green: 224/255, blue: 140/255, alpha: 1)
            }
        } else {
            return UIColor(red: 38/255, green: 224/255, blue: 140/255, alpha: 1)
        }
    }
}


extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.5
        animation.values = [-10.0, 10.0, -10.0, 10.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}
