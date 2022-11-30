//
//  TextField+Configuration.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 30.11.2022.
//

import Foundation

extension TextField {

    final class Configuration {
        var textField: TextFieldConfiguration
        let headerLabel: UILabel.Configuration

        weak var updater: ITextFieldUpdater?

        init(
            textField: TextFieldConfiguration,
            headerLabel: UILabel.Configuration
        ) {
            self.textField = textField
            self.headerLabel = headerLabel
        }

        static let empty = Configuration(
            textField: TextFieldConfiguration
                .assembleWithRegularContentAndStyle(
                    delegate: nil, text: nil, placeholder: nil, hasClearButton: false
                ),
            headerLabel: UILabel.Configuration(
                content: .plain(text: nil, style: .bodyM())
            )
        )
    }
}

extension TextField {

    struct TextFieldConfiguration {

        let delegate: UITextFieldDelegate?
        var eventHandler: ((TextFieldEvent, TextField) -> Void)?
        let content: UILabel.Content
        let placeholder: UILabel.Content

        // style
        var tintColor: UIColor?
        var rightAccessoryView: AccessoryView?
        var isSecure = false
        var keyboardType: UIKeyboardType = .default

        static func assembleWithRegularContentAndStyle(
            delegate: UITextFieldDelegate?,
            text: String?,
            placeholder: String?,
            eventHandler: ((TextFieldEvent, TextField) -> Void)? = nil,
            hasClearButton: Bool,
            keyboardType: UIKeyboardType = .default,
            isSecure: Bool = false
        ) -> Self {
            let textStyle = UILabel.Style
                .bodyL()
                .set(textColor: ASDKColors.Text.primary.color)

            return self.init(
                delegate: delegate,
                eventHandler: eventHandler,
                content: .plain(text: text, style: textStyle),
                placeholder: .plain(text: placeholder, style: textStyle),
                tintColor: .systemBlue,
                rightAccessoryView: hasClearButton ? AccessoryView(kind: .clearButton) : nil,
                isSecure: isSecure,
                keyboardType: keyboardType
            )
        }
    }

    struct AccessoryView {
        enum Kind {
            case custom(content: IAccessoryViewContent)
            case clearButton
        }

        let kind: Kind
        let content: IAccessoryViewContent

        init(kind: Kind) {
            self.kind = kind
            switch kind {
            case .clearButton:
                content = DeleteButtonContent()
            case let .custom(content):
                self.content = content
            }
        }
    }
}
