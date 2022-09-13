//
//  InputCardCVCRequisitesPresenter.swift
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

protocol InputCardCVCRequisitesViewOutConnection {
    func present(responderListener: BecomeFirstResponderListener?, inputView: InputCardCVCRequisitesPresenterProtocol?)

    func cardCVC() -> String?
}

class InputCardCVCRequisitesPresenter: NSObject {
    private weak var maskedTextFieldDelegate: MaskedTextFieldDelegate!
    private weak var becomeFirstResponderListener: BecomeFirstResponderListener?
    private weak var inputView: InputCardCVCRequisitesPresenterProtocol?
    private var maskFormatCVC = "[000]"
    private var inputCardCVC: String?

    private var colorError = UIColor.systemRed
    private var colorNormal: UIColor = {
        if #available(iOS 13, *) {
            return .label
        } else {
            return .black
        }
    }()

    private var colorDisable = UIColor.systemGray
}

extension InputCardCVCRequisitesPresenter: UITextFieldDelegate {
    // MARK: UITextFieldDelegate

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return becomeFirstResponderListener?.textFieldShouldBecomeFirstResponder(textField) ?? true
    }

    func textFieldShouldEndEditing(_: UITextField) -> Bool {
        return true
    }

    func textFieldDidEndEditing(_: UITextField) {}

    func textField(_: UITextField, shouldChangeCharactersIn _: NSRange, replacementString _: String) -> Bool {
        return true
    }

    func textFieldShouldClear(_: UITextField) -> Bool {
        return true
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        return true
    }
}

extension InputCardCVCRequisitesPresenter: MaskedTextFieldDelegateListener {
    // MARK: MaskedTextFieldDelegateListener

    func textField(_ textField: UITextField, didFillMask _: Bool, extractValue value: String) {
        if let inputViewStatus = inputView as? InputViewStatus {
            inputViewStatus.setStatus(.normal, statusText: nil)
        }

        if inputView?.textFieldCardCVC == textField {
            inputCardCVC = value
        }
    }
}

extension InputCardCVCRequisitesPresenter: InputCardCVCRequisitesViewOutConnection {
    func present(responderListener: BecomeFirstResponderListener?, inputView: InputCardCVCRequisitesPresenterProtocol?) {
        self.inputView?.textFieldCardCVC.text = nil
        self.inputView?.textFieldCardCVC.delegate = maskedTextFieldDelegate

        self.inputView = inputView

        maskedTextFieldDelegate = MaskedTextFieldDelegate()
        maskedTextFieldDelegate.maskFormat = maskFormatCVC
        maskedTextFieldDelegate.listener = self

        becomeFirstResponderListener = responderListener
        inputView?.textFieldCardCVC.text = nil
        inputView?.textFieldCardCVC.delegate = maskedTextFieldDelegate
    }

    func cardCVC() -> String? {
        return inputCardCVC
    }
}
