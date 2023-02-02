//
//  TextField+Configuration.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 30.11.2022.
//

import UIKit

extension FloatingTextField {
    final class Configuration {
        var textField: TextFieldConfiguration
        let headerLabel: UILabel.Configuration

        init(textField: TextFieldConfiguration, headerLabel: UILabel.Configuration) {
            self.textField = textField
            self.headerLabel = headerLabel
        }
    }
}

struct TextFieldConfiguration {

    let delegate: FloatingTextFieldDelegate?
    let content: UILabel.Content

    static func assembleWithRegularContentAndStyle(
        delegate: FloatingTextFieldDelegate?,
        text: String?
    ) -> Self {
        let textStyle = UILabel.Style
            .bodyL()
            .set(textColor: ASDKColors.Text.primary.color)

        return self.init(
            delegate: delegate,
            content: .plain(text: text, style: textStyle)
        )
    }
}
