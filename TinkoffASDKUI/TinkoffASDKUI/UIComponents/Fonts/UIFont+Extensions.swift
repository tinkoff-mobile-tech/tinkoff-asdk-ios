//
//  UIFont+Extensions.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 06.02.2023.
//

import UIKit

extension UIFont {
    // MARK: Heading

    static var headingLarge: UIFont {
        .systemFont(ofSize: 30, weight: .bold)
    }

    static var headingMedium: UIFont {
        .systemFont(ofSize: 20, weight: .bold)
    }

    static var headingSmall: UIFont {
        .systemFont(ofSize: 17, weight: .semibold)
    }

    static var headingSmallBold: UIFont {
        .systemFont(ofSize: 17, weight: .bold)
    }

    // MARK: Body

    static var bodyLarge: UIFont {
        .systemFont(ofSize: 17, weight: .regular)
    }

    static var bodyMedium: UIFont {
        .systemFont(ofSize: 15, weight: .regular)
    }

    // MARK: UI

    static var uiMediumBold: UIFont {
        .systemFont(ofSize: 15, weight: .semibold)
    }

    static var uiSmall: UIFont {
        .systemFont(ofSize: 13, weight: .regular)
    }

    static var uiSmallBold: UIFont {
        .systemFont(ofSize: 13, weight: .semibold)
    }

    static var uiExtraSmall: UIFont {
        .systemFont(ofSize: 12, weight: .regular)
    }

    static var uiExtraSmallBold: UIFont {
        .systemFont(ofSize: 12, weight: .semibold)
    }

    // MARK: Numbers

    static var numbersExtraLarge: UIFont {
        .systemFont(ofSize: 34, weight: .bold)
    }

    static var medium: UIFont {
        .systemFont(ofSize: 20, weight: .bold)
    }
}
