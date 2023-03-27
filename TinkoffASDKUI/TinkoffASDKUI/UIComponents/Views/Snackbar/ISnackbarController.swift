//
//  ISnackbarController.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 24.03.2023
//

import UIKit

protocol ISnackbarController {
    func showSnackView(config: SnackbarView.Configuration, animated: Bool, completion: ((Bool) -> Void)?)
    func hideSnackView(animated: Bool, completion: ((Bool) -> Void)?)
}

extension ISnackbarController {

    func showSnackView(config: SnackbarView.Configuration, animated: Bool) {
        showSnackView(config: config, animated: animated, completion: nil)
    }

    func hideSnackView(animated: Bool) {
        hideSnackView(animated: animated, completion: nil)
    }

    func hideSnackView() {
        hideSnackView(animated: true, completion: nil)
    }
}
