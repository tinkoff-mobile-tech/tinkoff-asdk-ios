//
//  CardFieldView + Config.swift
//  Pods-ASDKSample
//
//  Created by Ivan Glushko on 25.11.2022.
//

import UIKit

extension CardFieldView {

    final class Config {
        let data: Data
        let style: Style
        var dynamicCardIcon: DynamicIconCardView.Model

        let expirationTextFieldConfig: TextField.Configuration
        let cardNumberTextFieldConfig: TextField.Configuration
        let cvcTextFieldConfig: TextField.Configuration

        var onDidConfigure: (() -> Void)?

        init(
            data: Data,
            style: Style,
            dynamicCardIcon: DynamicIconCardView.Model,
            expirationTextFieldConfig: TextField.Configuration,
            cardNumberTextFieldConfig: TextField.Configuration,
            cvcTextFieldConfig: TextField.Configuration
        ) {
            self.data = data
            self.style = style
            self.dynamicCardIcon = dynamicCardIcon
            self.expirationTextFieldConfig = expirationTextFieldConfig
            self.cardNumberTextFieldConfig = cardNumberTextFieldConfig
            self.cvcTextFieldConfig = cvcTextFieldConfig
        }
    }

    struct Data {}

    struct Style {
        let card: Card
        let expiration: Expiration
        let cvc: Cvc

        struct Card {
            let backgroundColor: UIColor?
            let cornerRadius: CGFloat
        }

        struct Expiration {
            let backgroundColor: UIColor?
            let cornerRadius: CGFloat
        }

        struct Cvc {
            let backgroundColor: UIColor?
            let cornerRadius: CGFloat
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
            data: data.cardFieldData,
            style: .regular,
            dynamicCardIcon: DynamicIconCardView.Model(data: data.dynamicCardIconData),
            expirationTextFieldConfig: TextField.Configuration(
                textField: .assembleWithRegularContentAndStyle(
                    delegate: data.expirationTextFieldData.delegate,
                    text: data.expirationTextFieldData.text,
                    placeholder: data.expirationTextFieldData.placeholder,
                    hasClearButton: false,
                    keyboardType: .decimalPad
                ),
                headerLabel: UILabel.Configuration(
                    content: .plain(text: data.expirationTextFieldData.headerText, style: headerLabelStyle)
                )
            ),
            cardNumberTextFieldConfig: TextField.Configuration(
                textField: .assembleWithRegularContentAndStyle(
                    delegate: data.cardNumberTextFieldData.delegate,
                    text: data.cardNumberTextFieldData.text,
                    placeholder: data.cardNumberTextFieldData.placeholder,
                    hasClearButton: true,
                    keyboardType: .decimalPad
                ),
                headerLabel: UILabel.Configuration(
                    content: .plain(text: data.cardNumberTextFieldData.headerText, style: headerLabelStyle)
                )
            ),
            cvcTextFieldConfig: TextField.Configuration(
                textField: .assembleWithRegularContentAndStyle(
                    delegate: data.cvcTextFieldData.delegate,
                    text: data.cvcTextFieldData.text,
                    placeholder: data.cvcTextFieldData.placeholder,
                    hasClearButton: false,
                    keyboardType: .decimalPad,
                    isSecure: true
                ),
                headerLabel: UILabel.Configuration(
                    content: .plain(text: data.cvcTextFieldData.headerText, style: headerLabelStyle)
                )
            )
        )
    }
}
