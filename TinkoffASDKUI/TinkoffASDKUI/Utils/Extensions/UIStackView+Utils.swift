//
//  UIStackView+Utils.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 12.01.2023.
//

import UIKit

extension UIStackView {
    func addArrangedSubviews(_ subviews: [UIView]) {
        subviews.forEach { addArrangedSubview($0) }
    }

    func addArrangedSubviews(_ subviews: UIView...) {
        addArrangedSubviews(subviews)
    }
}
