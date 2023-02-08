//
//  UIFont+Extensions.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 06.02.2023.
//

import UIKit

extension UIFont {
    static var uiSmallBold: UIFont {
        .systemFont(ofSize: 13, weight: .bold)
    }

    static var uiSmall: UIFont {
        .systemFont(ofSize: 13, weight: .regular)
    }

    static var bodyMedium: UIFont {
        .systemFont(ofSize: 15, weight: .regular)
    }

    static var bodyLarge: UIFont {
        .systemFont(ofSize: 17, weight: .regular)
    }

    static var headingMedium: UIFont {
        .systemFont(ofSize: 20, weight: .bold)
    }
}
