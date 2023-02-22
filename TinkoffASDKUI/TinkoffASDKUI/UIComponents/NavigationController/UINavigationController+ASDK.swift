//
//  UINavigationController+ASDK.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 22.02.2023.
//

import UIKit

extension UINavigationController {
    static func withASDKBar(rootViewController: UIViewController? = nil) -> UINavigationController {
        let navigationController = rootViewController.map(UINavigationController.init) ?? UINavigationController()

        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithTransparentBackground()
            navBarAppearance.backgroundColor = ASDKColors.Background.elevation1.color
            navigationController.navigationBar.standardAppearance = navBarAppearance
            navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance
            navigationController.navigationBar.compactAppearance = navBarAppearance
        }

        return navigationController
    }
}
