//
//  UIApplication+Ext.swift
//  popup
//
//  Created by Ivan Glushko on 18.11.2022.
//

import UIKit

// MARK: - Top ViewController

extension UIApplication {
    class func topViewController(
        controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
    ) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

// MARK: - Snack

extension UIApplication {

    fileprivate static let snackViewController = SnackbarViewController.assemble()

    func showSnack(config: SnackbarView.Configuration, completion: (() -> Void)? = nil) {
        let topViewController = UIApplication.topViewController()
        topViewController?.present(
            UIApplication.snackViewController,
            animated: false,
            completion: {
                UIApplication.snackViewController.showSnackView(
                    config: config,
                    completion: completion
                )
            }
        )
    }

    func hideSnack(animated: Bool = true, completion: (() -> Void)? = nil) {
        UIApplication.snackViewController.hideSnackView(animated: animated, completion: completion)
    }

    func showSnackFor(
        seconds: Double,
        config: SnackbarView.Configuration,
        didShowCompletion: (() -> Void)? = nil,
        didHideCompletion: (() -> Void)? = nil
    ) {
        assert(seconds > 0)
        DispatchQueue.main.asyncAfter(
            deadline: .now() + seconds,
            execute: {
                self.hideSnack(completion: didHideCompletion)
            }
        )

        showSnack(config: config, completion: didShowCompletion)
    }
}
