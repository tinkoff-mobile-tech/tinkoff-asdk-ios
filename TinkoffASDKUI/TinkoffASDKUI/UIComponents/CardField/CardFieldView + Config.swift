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

        let expirationTextFieldConfig: FloatingTextField.Configuration
        let cardNumberTextFieldConfig: FloatingTextField.Configuration
        let cvcTextFieldConfig: FloatingTextField.Configuration

        var onDidConfigure: (() -> Void)?

        init(
            dynamicCardIcon: DynamicIconCardView.Model,
            expirationTextFieldConfig: FloatingTextField.Configuration,
            cardNumberTextFieldConfig: FloatingTextField.Configuration,
            cvcTextFieldConfig: FloatingTextField.Configuration
        ) {
            self.dynamicCardIcon = dynamicCardIcon
            self.expirationTextFieldConfig = expirationTextFieldConfig
            self.cardNumberTextFieldConfig = cardNumberTextFieldConfig
            self.cvcTextFieldConfig = cvcTextFieldConfig
        }
    }
}

// MARK: - Config inits

extension CardFieldView.Config {

    static func assembleWithRegularStyle(data: CardFieldView.DataDependecies) -> Self {
        let headerLabelStyle = UILabel.Style
            .bodyL()
            .set(textColor: ASDKColors.Text.secondary.color)

        return Self(
            dynamicCardIcon: DynamicIconCardView.Model(data: data.dynamicCardIconData),
            expirationTextFieldConfig: FloatingTextField.Configuration(
                textField: .assembleWithRegularContentAndStyle(
                    delegate: data.expirationTextFieldData.delegate,
                    text: data.expirationTextFieldData.text
                ),
                headerLabel: UILabel.Configuration(
                    content: .plain(text: data.expirationTextFieldData.headerText, style: headerLabelStyle)
                )
            ),
            cardNumberTextFieldConfig: FloatingTextField.Configuration(
                textField: .assembleWithRegularContentAndStyle(
                    delegate: data.cardNumberTextFieldData.delegate,
                    text: data.cardNumberTextFieldData.text
                ),
                headerLabel: UILabel.Configuration(
                    content: .plain(text: data.cardNumberTextFieldData.headerText, style: headerLabelStyle)
                )
            ),
            cvcTextFieldConfig: FloatingTextField.Configuration(
                textField: .assembleWithRegularContentAndStyle(
                    delegate: data.cvcTextFieldData.delegate,
                    text: data.cvcTextFieldData.text
                ),
                headerLabel: UILabel.Configuration(
                    content: .plain(text: data.cvcTextFieldData.headerText, style: headerLabelStyle)
                )
            )
        )
    }
}
