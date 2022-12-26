//
//  UIAlertController+Ext.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 21.12.2022.
//

import UIKit

extension UIAlertController {

    static func okAlert(
        title: String?,
        message: String?,
        buttonTitle: String?
    ) -> UIAlertController {

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        let ok = UIAlertAction(
            title: buttonTitle,
            style: .default
        )

        alert.addAction(ok)
        return alert
    }
}
