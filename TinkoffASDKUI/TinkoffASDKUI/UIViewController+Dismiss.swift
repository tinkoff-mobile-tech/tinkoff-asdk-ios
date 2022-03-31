//
//  UIViewController+Dismiss.swift
//  TinkoffASDKUI
//
//  Created by Grigory on 11.12.2020.
//

import UIKit

extension UIViewController {
    func dismissPresentedIfNeeded(animated: Bool = true, then completion: (() -> Void)? = nil) {
        if let presentedViewController = self.presentedViewController {
            if presentedViewController.isBeingPresented {
                transitionCoordinator?.animate(alongsideTransition: nil, completion: { _ in
                    self.dismiss(animated: animated, completion: completion)
                })
            } else if presentedViewController.isBeingDismissed {
                transitionCoordinator?.animate(alongsideTransition: nil, completion: { _ in
                    completion?()
                })
            } else {
                self.dismiss(animated: animated) {
                    completion?()
                }
            }
        } else {
            completion?()
        }
    }
}
