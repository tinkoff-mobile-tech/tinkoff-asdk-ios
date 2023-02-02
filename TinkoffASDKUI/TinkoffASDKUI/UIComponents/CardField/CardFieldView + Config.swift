//
//  CardFieldView + Config.swift
//  Pods-ASDKSample
//
//  Created by Ivan Glushko on 25.11.2022.
//

import UIKit

extension CardFieldView {

    final class Config {
        var dynamicCardIcon: DynamicIconCardView.Model

        let expirationFieldDelegate: FloatingTextFieldDelegate?
        let cardNumberFieldDelegate: FloatingTextFieldDelegate?
        let cvcFieldDelegate: FloatingTextFieldDelegate?

        init(
            dynamicCardIcon: DynamicIconCardView.Model,
            expirationFieldDelegate: FloatingTextFieldDelegate,
            cardNumberFieldDelegate: FloatingTextFieldDelegate,
            cvcFieldDelegate: FloatingTextFieldDelegate
        ) {
            self.dynamicCardIcon = dynamicCardIcon
            self.expirationFieldDelegate = expirationFieldDelegate
            self.cardNumberFieldDelegate = cardNumberFieldDelegate
            self.cvcFieldDelegate = cvcFieldDelegate
        }
    }
}
