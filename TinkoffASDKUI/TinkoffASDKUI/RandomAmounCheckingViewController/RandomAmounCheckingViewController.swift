//
//  RandomAmounCheckingViewController.swift
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

class RandomAmounCheckingViewController: ConfirmViewController {
    enum TableViewCells {
        case title
        case textField
        case secureLogos
    }

    weak var alertViewHelper: AcquiringAlertViewProtocol?
    var completeHandler: ((_ result: Double) -> Void)?

    @IBOutlet var viewWaiting: UIView!
    @IBOutlet private var tableView: UITableView!

    private var tableViewCells: [TableViewCells]!
    private var inputValue: String?
    private weak var inputAccessoryViewWithButton: ButtonInputAccessoryView?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.TinkoffAcquiring.View.Title.confimration

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowOnTableView(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideOnTableView(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        tableViewCells = [.title, .textField, .secureLogos]

        tableView.register(UINib(nibName: "TextFieldTableViewCell", bundle: .uiResources), forCellReuseIdentifier: "TextFieldTableViewCell")
        tableView.register(UINib(nibName: "AmountTableViewCell", bundle: .uiResources), forCellReuseIdentifier: "AmountTableViewCell")
        tableView.register(UINib(nibName: "PSLogoTableViewCell", bundle: .uiResources), forCellReuseIdentifier: "PSLogoTableViewCell")

        tableView.dataSource = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        inputField()?.textField.becomeFirstResponder()
    }

    private func inputField() -> InputFieldTableViewCellStatusProtocol? {
        if let index = tableViewCells.firstIndex(of: .textField), let inputField = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? InputFieldTableViewCellStatusProtocol {
            return inputField
        }

        return nil
    }

    private func onButtonAddTouch() {
        if validate(inputValue) {
            if let value = inputValue {
                let desValue = value.replacingOccurrences(of: ",", with: ".")
                if let amount = Double(desValue), amount > 0.0 {
                    if let inputField = inputField() {
                        inputField.textField.resignFirstResponder()
                    }

                    completeHandler?(amount)
                }
            }
        } else {
            if let inputField = inputField() {
                inputField.setStatus(.error, statusText: L10n.TinkoffAcquiring.Error.loopAmount)
            }
        }
    } // onButtonAddTouch

    private func validate(_ validateValue: String?) -> Bool {
        if let value = validateValue {
            let desValue = value.replacingOccurrences(of: ",", with: ".")
            if let amount = Double(desValue), amount > 0.0 {
                return true
            }
        }

        return false
    }

    // MARK: FirstResponder, Resize Content Insets

    @objc func keyboardWillShowOnTableView(notification: NSNotification) {
        keyboardWillShow(notification: notification)
    }

    @objc func keyboardWillHideOnTableView(notification: NSNotification) {
        keyboardWillHide(notification: notification)
    }

    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo as NSDictionary?, let keyboardFrame = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let inputAccessoryViewHeight: CGFloat = (view.firstResponder?.inputAccessoryView?.frame.size.height) ?? 0
            let keyboardContentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight + inputAccessoryViewHeight, right: 0)
            tableView.contentInset = keyboardContentInset
        }
    }

    func keyboardDidShow() {
        if let cell: UITableViewCell = UIView.searchTableViewCell(by: view.firstResponder), let indexPath = tableView.indexPath(for: cell) {
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    func keyboardWillHide(notification _: NSNotification) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.tableView.contentInset = UIEdgeInsets.zero
        }
    }
}

extension RandomAmounCheckingViewController: UITableViewDataSource {
    // MARK: UITableViewDataSource

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return tableViewCells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableViewCells[indexPath.row] {
        case .title:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "AmountTableViewCell") as? AmountTableViewCell {
                cell.labelTitle.text = L10n.TinkoffAcquiring.Text.loopConfirmation
                return cell
            }

        case .textField:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell") as? TextFieldTableViewCell {
                cell.textField.delegate = self
                cell.textField.keyboardType = .decimalPad
                cell.labelHint.text = L10n.TinkoffAcquiring.Hint.loopAmount
                cell.textField.placeholder = L10n.TinkoffAcquiring.Placeholder.loopAmount
                return cell
            }

        case .secureLogos:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PSLogoTableViewCell") as? PSLogoTableViewCell {
                return cell
            }
        }

        return tableView.defaultCell()
    }
}

extension RandomAmounCheckingViewController: BecomeFirstResponderListener {
    func textFieldShouldBecomeFirstResponder(_: UITextField) -> Bool {
        return true
    }
}

extension RandomAmounCheckingViewController: UITextFieldDelegate {
    // MARK: UITextFieldDelegate

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let accessoryView = Bundle.uiResources.loadNibNamed("ButtonInputAccessoryView", owner: nil, options: nil)?.first as? ButtonInputAccessoryView {
            accessoryView.buttonAction.setTitle(L10n.TinkoffAcquiring.Button.confirm, for: .normal)
            accessoryView.onButtonTouchUpInside = { [weak self] in
                self?.onButtonAddTouch()
            }

            textField.inputAccessoryView = accessoryView
            inputAccessoryViewWithButton = accessoryView
        }

        inputAccessoryViewWithButton?.updateViewSize(for: textField.traitCollection)
        inputAccessoryViewWithButton?.buttonAction.setTitle(L10n.TinkoffAcquiring.Button.addCard, for: .normal)

        return true
    }

    func textFieldDidBeginEditing(_: UITextField) {
        inputAccessoryViewWithButton?.buttonAction.isEnabled = validate(inputValue)
    }

    func textFieldShouldEndEditing(_: UITextField) -> Bool {
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        inputValue = textField.text
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let inputFieldCell: InputFieldTableViewCellStatusProtocol = UIView.searchTableViewCell(by: textField) {
            tableView.beginUpdates()
            inputFieldCell.setStatus(.normal, statusText: nil)
            tableView.endUpdates()
        }

        let text: String = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        inputValue = text
        inputAccessoryViewWithButton?.buttonAction.isEnabled = validate(inputValue)

        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if let inputField: InputFieldTableViewCellStatusProtocol = UIView.searchTableViewCell(by: textField) {
            inputField.setStatus(.normal, statusText: nil)
        }

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }
}
