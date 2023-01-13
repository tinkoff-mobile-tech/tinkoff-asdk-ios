//
//  UIAlertController+Ext.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 21.12.2022.
//

import UIKit

struct OkAlertData {
    var title: String?
    var message: String?
    var buttonTitle: String?
}

extension UIAlertController {

    static func okAlert(data: OkAlertData) -> UIAlertController {

        let alert = UIAlertController(
            title: data.title,
            message: data.message,
            preferredStyle: .alert
        )

        let ok = UIAlertAction(
            title: data.buttonTitle,
            style: .default
        )

        alert.addAction(ok)
        return alert
    }
}
