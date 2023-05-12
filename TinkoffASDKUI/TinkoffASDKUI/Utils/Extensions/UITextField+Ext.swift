//
//  UITextField+Ext.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 31.01.2023.
//

import UIKit

extension UITextField {
    func setPlaceholder(color: UIColor) {
        let placeholderText = placeholder ?? ""
        attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [.foregroundColor: color])
    }
}
