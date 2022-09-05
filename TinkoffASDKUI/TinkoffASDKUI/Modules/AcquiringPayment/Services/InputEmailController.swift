//
//  InputEmailController.swift
//  TinkoffASDKUI
//
//  Copyright (c) 2020 Tinkoff Bank
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

protocol InputEmailControllerOutConnection: InputViewStatus {
    func present(hint: String?, preFilledValue: String?, textFieldCell: InputFieldTableViewCellStatusProtocol, tableView: UITableView, firstResponderListener: BecomeFirstResponderListener?)

    func validateEmail(_ value: String?) -> Bool

    func inputValue() -> String?
}

class InputEmailController: NSObject, InputEmailControllerOutConnection {
    private weak var textFieldCell: InputFieldTableViewCellStatusProtocol!
    private weak var tableView: UITableView!
    private weak var becomeFirstResponderListener: BecomeFirstResponderListener?

    private var hint: String?
    private var text: String?

    func present(hint: String?,
                 preFilledValue: String?,
                 textFieldCell: InputFieldTableViewCellStatusProtocol,
                 tableView: UITableView,
                 firstResponderListener: BecomeFirstResponderListener?)
    {
        if let value = hint {
            self.hint = value
        } else {
            self.hint = L10n.TinkoffAcquiring.Placeholder.sendReceiptToEmail
        }

        self.textFieldCell = textFieldCell
        self.textFieldCell.textField.keyboardType = .emailAddress

        self.tableView = tableView
        becomeFirstResponderListener = firstResponderListener

        if text == nil {
            text = preFilledValue
        }

        textFieldCell.textField.delegate = self
        textFieldCell.textField.text = text

        prepareResignFirstResponder()
    }

    func validateEmail(_ value: String?) -> Bool {
        if let email = value, email.isEmpty == false {
            let predicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
            let result = predicate.evaluate(with: email)
            if result == false {
                tableView.beginUpdates()
                textFieldCell.setStatus(.error, statusText: L10n.TinkoffAcquiring.Text.Status.Error.email)
                tableView.endUpdates()
            }

            return result
        } else {
            tableView.beginUpdates()
            textFieldCell.setStatus(.error, statusText: L10n.TinkoffAcquiring.Text.Status.Error.emailEmpty)
            tableView.endUpdates()
        }

        return false
    }

    func inputValue() -> String? {
        if validateEmail(textFieldCell.textField.text) {
            return textFieldCell.textField.text
        }

        return nil
    }

    func setStatus(_ value: InputFieldTableViewCellStatus, statusText: String?) {
        textFieldCell.setStatus(value, statusText: statusText)
    }

    private func prepareResignFirstResponder() {
        if let text = textFieldCell.textField.text, text.isEmpty == false {
            textFieldCell.labelHint.text = hint
        } else {
            textFieldCell.textField.placeholder = hint
            textFieldCell.labelHint.text = nil
        }
    }
}

extension InputEmailController: UITextFieldDelegate {
    // MARK: UITextFieldDelegate

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        tableView.beginUpdates()
        textFieldCell.labelHint.text = hint
        textFieldCell.textField.placeholder = nil
        tableView.endUpdates()

        return becomeFirstResponderListener?.textFieldShouldBecomeFirstResponder(textField) ?? true
    }

    func textFieldDidBeginEditing(_: UITextField) {}

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        prepareResignFirstResponder()
        _ = validateEmail(textField.text)

        text = textField.text

        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        tableView.beginUpdates()
        textFieldCell.setStatus(.normal, statusText: nil)
        tableView.endUpdates()
        text = (textField.text! as NSString).replacingCharacters(in: range, with: string)

        return true
    }

    func textFieldShouldClear(_: UITextField) -> Bool {
        tableView.beginUpdates()
        textFieldCell.setStatus(.normal, statusText: nil)
        tableView.endUpdates()
        text = nil

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        prepareResignFirstResponder()
        textField.resignFirstResponder()

        if validateEmail(textField.text) == false {
            tableView.beginUpdates()
            textFieldCell.setStatus(.error, statusText: nil)
            tableView.endUpdates()
        }

        return true
    }
}
