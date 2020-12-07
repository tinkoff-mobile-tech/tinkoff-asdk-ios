//
//  UIColor+Dynamic.swift
//  TinkoffASDKUI
//
//  Created by grisha on 07.12.2020.
//

import UIKit

extension UIColor {
    static func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(dynamicProvider: {
                $0.userInterfaceStyle == .dark ? dark : light
            })
        }
        return light
    }
}

public extension UIColor {
    static var dynamic: Dynamic {
        return Dynamic()
    }
    
    struct Dynamic {
        public struct Button {
            public struct Sbp {
                public var background: UIColor {
                    return UIColor.dynamicColor(light: .black, dark: .white)
                }
                
                public var tint: UIColor {
                    return UIColor.dynamicColor(light: .white, dark: .black)
                }
            }
            
            public var sbp: Sbp {
                return Sbp()
            }
        }
        
        public var button: Button {
            return Button()
        }
    }
}
