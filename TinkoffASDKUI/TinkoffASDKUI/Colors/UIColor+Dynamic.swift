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

extension UIColor {
    static var asdk = ASDKColors()
}
struct ASDKColors {}

extension ASDKColors {
    var dynamic: Dynamic {
        return Dynamic()
    }
    
    var yellow: UIColor {
        return UIColor(hex: "#FFDD2D") ?? .clear
    }
    
    var black: UIColor {
        return UIColor(hex: "#333333") ?? .clear
    }
    
    var textPrimary: UIColor {
        return UIColor(hex: "#333333") ?? .clear
    }
    
    var n3: UIColor {
        return UIColor(hex: "#9299A2") ?? .clear
    }
    
    var n7: UIColor {
        return UIColor(hex: "#F6F7F8") ?? .clear
    }
    
    var n8: UIColor {
        return UIColor(hex: "#428BF9") ?? .clear
    }
    
    var n14: UIColor {
        return UIColor(hex: "#FFFFFF") ?? .clear
    }
    
    var n15: UIColor {
        return UIColor(hex: "#000000") ?? .clear
    }
    
    var n16: UIColor {
        return UIColor(hex: "#1C1C1E") ?? .clear
    }
    
    var n18: UIColor {
        return UIColor(hex: "#2C2C2E") ?? .clear
    }
    
    var lightGray: UIColor {
        return UIColor(hex: "#F7F7F7") ?? .clear
    }
    
    var darkGray: UIColor {
        return UIColor(hex: "#C7C9CC") ?? .clear
    }
    
    struct Dynamic {
        public struct Background {
            public var base: UIColor {
                return UIColor.dynamicColor(light: UIColor.asdk.n14,
                                            dark: UIColor.asdk.n15)
            }
            
            public var elevation1: UIColor {
                return UIColor.dynamicColor(light: UIColor.asdk.n14,
                                            dark: UIColor.asdk.n16)
            }
            
            public var elevation2: UIColor {
                return UIColor.dynamicColor(light: UIColor.asdk.n14,
                                            dark: UIColor.asdk.n18)
            }
            
            public var separator: UIColor {
                return UIColor.dynamicColor(light: UIColor.asdk.darkGray,
                                            dark: UIColor.asdk.black)
            }
        }
        
        public struct Text {
            public var primary: UIColor {
                return UIColor.dynamicColor(light: UIColor.asdk.textPrimary,
                                            dark: UIColor.asdk.n7)
            }
        }
        
        public struct Button {
            public struct Sbp {
                public var background: UIColor {
                    return UIColor.dynamicColor(light: .black,
                                                dark: .white)
                }
                
                public var tint: UIColor {
                    return UIColor.dynamicColor(light: .white,
                                                dark: .black)
                }
            }
            
            public var sbp: Sbp {
                return Sbp()
            }
        }
        
        public var background: Background {
            return Background()
        }
        
        public var text: Text {
            return Text()
        }
        
        public var button: Button {
            return Button()
        }
    }
}
