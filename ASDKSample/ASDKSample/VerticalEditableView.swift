//
//
//  VerticalEditableView.swift
//
//  Copyright (c) 2021 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

typealias VerticalEditableTableCell = GenericTableCell<VerticalEditableView>

final class VerticalEditableView: UIView, ConfigurableAndReusable, Stylable {

    struct Model {
        let labelText: String?
        let textFieldText: String?
        var isEditable = true
    }

    struct Style {
        static let basic = Style()

        var label = Label()
        var textField = TextField()

        struct Label {
            var font: UIFont = .systemFont(ofSize: 14)
            var textColor: UIColor = .black
            var insets: UIEdgeInsets = .zero
        }

        struct TextField {
            var font: UIFont = .systemFont(ofSize: 16)
            var textColor: UIColor = .gray
            var insets = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
        }
    }

    private let label = UILabel()
    let textField = UITextField()

    private func setupViews(style: Style) {
        addSubview(label)
        addSubview(textField)

        label.textColor = style.label.textColor
        label.font = style.label.font
        textField.textColor = style.textField.textColor
        textField.font = style.textField.font
    }

    func configure(model: Model) {
        label.text = model.labelText
        textField.text = model.textFieldText
        changeIsEditable(to: model.isEditable)
    }

    func changeIsEditable(to value: Bool) {
        textField.isEnabled = value
    }

    func getTextFieldText() -> String {
        textField.text ?? ""
    }

    func prepareForReuse() {
        label.text = nil
        textField.text = nil
    }

    func apply(style: Style) {
        setupViews(style: style)

        let insetsLabel = style.label.insets
        label.makeConstraints { make in
            [
                make.topAnchor.constraint(equalTo: make.forcedSuperview.topAnchor, constant: insetsLabel.top),
                make.leftAnchor.constraint(equalTo: make.forcedSuperview.leftAnchor, constant: insetsLabel.left),
                make.rightAnchor.constraint(equalTo: make.forcedSuperview.rightAnchor, constant: -insetsLabel.right),
                make.bottomAnchor.constraint(lessThanOrEqualTo: textField.bottomAnchor),
            ]
        }

        let insetsTextField = style.textField.insets

        textField.makeConstraints { make in
            [
                make.topAnchor.constraint(equalTo: label.bottomAnchor, constant: insetsTextField.top),
                make.leftAnchor.constraint(equalTo: make.forcedSuperview.leftAnchor, constant: insetsTextField.left),
                make.rightAnchor.constraint(equalTo: make.forcedSuperview.rightAnchor, constant: -insetsTextField.right),
                make.bottomAnchor.constraint(lessThanOrEqualTo: make.forcedSuperview.bottomAnchor),
            ]
        }
    }
}
