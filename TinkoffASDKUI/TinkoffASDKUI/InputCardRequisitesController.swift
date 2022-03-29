//
//  InputCardRequisitesController.swift
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

protocol BecomeFirstResponderListener: AnyObject {
    func textFieldShouldBecomeFirstResponder(_ textField: UITextField) -> Bool
}

protocol InputCardRequisitesDataSource: AnyObject {
    func setup(responderListener: BecomeFirstResponderListener?,
               inputView: InputRequisitesViewInConnection?,
               inputAccessoryView: InputAccessoryViewWithButton?,
               scaner: CardRequisitesScanerProtocol?)

    func setupForCVC(responderListener: BecomeFirstResponderListener?, inputView: InputRequisitesViewInConnection?)

    func requisies() -> (number: String?, expDate: String?, cvc: String?)

    var onButtonInputAccessoryTouch: (() -> Void)? { get set }
}

class InputCardRequisitesController: NSObject {
    // MARK: InputCardRequisitesDataSource

    var onButtonInputAccessoryTouch: (() -> Void)?

    enum InputState {
        case addRequisites
        case inputCardNumber
        case inputCardExpDate
        case inputCardCVC
    }

    private var maskedTextFieldCardNumberDelegate: MaskedTextFieldDelegate!
    private var maskedTextFieldCardExpDateDelegate: MaskedTextFieldDelegate!
    private var maskedTextFieldCardCVCDelegate: MaskedTextFieldDelegate!

    private weak var becomeFirstResponderListener: BecomeFirstResponderListener?
    private weak var inputView: InputRequisitesViewInConnection? {
        didSet {
            inputView?.onCardNumberTouch = { [weak self] in
                if self?.inputView?.labelShortCardNumber.isHidden == false {
                    self?.activateStep(.inputCardNumber)
                }
            }
        }
    }

    // input mask
    private lazy var maskFormat16 = "[0000] [0000] [0000] [0000]"
    private lazy var maskFormat19 = "[00000000] [00000000000]"
    private lazy var maskFormat22 = "[00000000] [00000000000000]"
    private lazy var maskFormatDate = "[00]/[00]"
    private lazy var maskFormatCVC = "[000]"
    // placeholders
    private lazy var placeholderCardNumber = AcqLoc.instance.localize("TinkoffAcquiring.placeholder.cardNumber")
    private var placeholderCardExpDate = "01/23"
    private var placeholderCardCVC = "CVC"
    // input value
    private var inputCardNumber: String?
    private var inputCardExpDate: String?
    private var inputCardCVC: String?
    // helpers
    private lazy var cardRequisitesBrandInfo: CardRequisitesBrandInfoProtocol = CardRequisitesBrandInfo()
    private lazy var cardRequisitesValidator: CardRequisitesValidatorProtocol = CardRequisitesValidator()
    private lazy var cardRequisitesInputMask: CardRequisitesInputMaskProtocol = CardRequisitesInputMask()
    private weak var cardRequisitesScaner: CardRequisitesScanerProtocol?

    private var colorError = UIColor.systemRed
    private var colorNormal: UIColor = {
        if #available(iOS 13, *) {
            return .label
        } else {
            return .black
        }
    }()

    private var inputAccessoryViewWithButton: InputAccessoryViewWithButton?

    private func onScanerResult(_ number: String?, _ mm: Int?, _ yy: Int?) {
        if let valueNumber = number, cardRequisitesValidator.validateCardNumber(number: valueNumber) {
            if let textField = inputView?.textFieldCardNumber {
                maskedTextFieldCardNumberDelegate.put(text: valueNumber, into: textField)

                inputView?.buttonRight.isHidden = true
                inputView?.buttonRight.setImage(nil, for: .normal)
                inputView?.onButtonRightTouch = nil
                inputView?.labelShortCardNumber.text = "*" + valueNumber.suffix(4)
            }

            if let valueMM = mm, let valueYY = yy, cardRequisitesValidator.validateCardExpiredDate(year: valueYY, month: valueMM) {
                if let textField = inputView?.textFieldCardExpDate {
                    maskedTextFieldCardExpDateDelegate.put(text: "\(valueMM)/\(valueYY)", into: textField)
                }
                activateStep(.inputCardCVC)
            } else {
                activateStep(.inputCardExpDate)
            }
        } else {
            activateStep(.inputCardNumber)
        }
    }

    private lazy var onScanner: (() -> Void) = { [weak self] in
        self?.cardRequisitesScaner?.startScanner(completion: { number, mm, yy in
            self?.onScanerResult(number, mm, yy)
        })
    }

    private lazy var onNext: (() -> Void) = { [weak self] in
        self?.activateStep(.inputCardExpDate)
    }

    func activateStep(_ inputState: InputState) {
        inputView?.labelShortCardNumber.isHidden = true
        inputView?.textFieldCardNumber.isHidden = true
        inputView?.textFieldCardExpDate.isHidden = true
        inputView?.textFieldCardCVC.isHidden = true
        inputView?.buttonRight.isHidden = true
        inputView?.buttonShowCardNumber.isHidden = true
        inputView?.onButtonRightTouch = nil

        switch inputState {
        case .inputCardNumber:
            inputView?.textFieldCardNumber.isHidden = false
            inputView?.textFieldCardNumber.becomeFirstResponder()
            if cardRequisitesValidator.validateCardNumber(number: inputView?.textFieldCardNumber.text) {
                activateNextButton()
            } else {
                activateScanerButton()
            }

        case .inputCardExpDate:
            inputView?.labelShortCardNumber.isHidden = false
            //
            inputView?.textFieldCardExpDate.isHidden = false
            inputView?.textFieldCardExpDate.becomeFirstResponder()
            //
            inputView?.buttonShowCardNumber.isHidden = false

            if cardRequisitesValidator.validateCardExpiredDate(value: inputCardExpDate) {
                inputView?.textFieldCardCVC.isHidden = false
            }

            if inputCardCVC != nil {
                inputView?.textFieldCardCVC.isHidden = false
            }

        case .inputCardCVC:
            inputView?.labelShortCardNumber.isHidden = false
            inputView?.textFieldCardExpDate.isHidden = false
            //
            inputView?.textFieldCardCVC.isHidden = false
            inputView?.textFieldCardCVC.becomeFirstResponder()
            //
            inputView?.buttonShowCardNumber.isHidden = false

        case .addRequisites:
            if cardRequisitesValidator.validateCardNumber(number: inputCardNumber) {
                if cardRequisitesValidator.validateCardExpiredDate(value: inputCardExpDate) {
                    activateStep(.inputCardCVC)
                } else {
                    activateStep(.inputCardExpDate)
                }
            } else {
                inputView?.textFieldCardNumber.isHidden = false
                activateScanerButton()
            }
        }
    }

    @objc func onButtonDoneTouchUpInside() {
        inputView?.textFieldCardNumber.resignFirstResponder()
        inputView?.textFieldCardExpDate.resignFirstResponder()
        inputView?.textFieldCardCVC.resignFirstResponder()

        onButtonInputAccessoryTouch?()
    }

    private func validateRequisites() -> Bool {
        return cardRequisitesValidator.validateCardNumber(number: inputCardNumber)
            && cardRequisitesValidator.validateCardExpiredDate(value: inputCardExpDate)
            && cardRequisitesValidator.validateCardCVC(cvc: inputCardCVC)
    }

    private func activateScanerButton() {
        if cardRequisitesScaner != nil {
            inputView?.buttonRight.isHidden = false
            inputView?.buttonRight.setImage(UIImage(named: "scan", in: .uiResources, compatibleWith: nil), for: .normal)
            inputView?.onButtonRightTouch = onScanner
        } else {
            inputView?.buttonRight.isHidden = true
            inputView?.buttonRight.setImage(nil, for: .normal)
            inputView?.onButtonRightTouch = nil
        }
    }

    private func activateNextButton() {
        inputView?.buttonRight.isHidden = false
        inputView?.buttonRight.setImage(UIImage(named: "next", in: .uiResources, compatibleWith: nil), for: .normal)
        inputView?.onButtonRightTouch = onNext
    }
}

extension InputCardRequisitesController: UITextFieldDelegate {
    // MARK: UITextFieldDelegate

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let cell: InputViewStatus = UIView.searchTableViewCell(by: textField) {
            cell.setStatus(.normal, statusText: nil)
        }

        inputAccessoryViewWithButton?.updateViewSize(for: textField.traitCollection)
        inputAccessoryViewWithButton?.buttonAction.setTitle(AcqLoc.instance.localize("TinkoffAcquiring.button.addCard"), for: .normal)
        textField.inputAccessoryView = inputAccessoryViewWithButton

        return becomeFirstResponderListener?.textFieldShouldBecomeFirstResponder(textField) ?? true
    }

    func textFieldDidBeginEditing(_: UITextField) {
        inputAccessoryViewWithButton?.buttonAction.isEnabled = validateRequisites()
    }

    func textFieldShouldEndEditing(_: UITextField) -> Bool {
        // print("\(textField.text ?? "")")
        return true
    }

    func textField(_: UITextField, shouldChangeCharactersIn _: NSRange, replacementString _: String) -> Bool {
        return true
    }

    func textFieldShouldClear(_: UITextField) -> Bool {
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == inputView?.textFieldCardNumber {
            textField.resignFirstResponder()
        } else if textField == inputView?.textFieldCardExpDate {
            activateStep(.inputCardNumber)
            return false
        } else if textField == inputView?.textFieldCardCVC {
            activateStep(.inputCardExpDate)
            return false
        }

        return true
    }
}

extension InputCardRequisitesController: MaskedTextFieldDelegateListener {
    // MARK: MaskedTextFieldDelegateListener

    func textField(_ textField: UITextField, didFillMask complete: Bool, extractValue value: String) {
        if let cell: InputViewStatus = UIView.searchTableViewCell(by: textField) {
            cell.setStatus(.normal, statusText: nil)
        }

        if inputView?.textFieldCardNumber == textField {
            inputView?.textFieldCardNumber.textColor = colorNormal
            inputCardNumber = value

            if let mask = cardRequisitesInputMask.inputMaskForCardNumber(number: value) {
                maskedTextFieldCardNumberDelegate.maskFormat = mask
            }

            cardRequisitesBrandInfo.cardBrandInfo(numbers: value, completion: { [weak self] cardNumber, icon, _ in
                if let number = cardNumber, number.isEmpty == false, self?.inputCardNumber?.hasPrefix(number) ?? false {
                    self?.inputView?.imageViewPSLogo.image = icon
                    self?.inputView?.imageViewPSLogoWidth.constant = 20
                } else {
                    self?.inputView?.imageViewPSLogo.image = nil
                    self?.inputView?.imageViewPSLogoWidth.constant = 0
                }
            })

            if cardRequisitesValidator.validateCardNumber(number: value) {
                activateNextButton()
                inputView?.labelShortCardNumber.text = "*" + value.suffix(4)
                if complete {
                    activateStep(.inputCardExpDate)
                }
            } else {
                activateScanerButton()
                if complete {
                    inputView?.textFieldCardNumber.textColor = colorError
                }
            }
        } else if inputView?.textFieldCardExpDate == textField {
            inputView?.textFieldCardExpDate.textColor = colorNormal
            inputCardExpDate = value

            if complete {
                if cardRequisitesValidator.validateCardExpiredDate(value: value) {
                    activateStep(.inputCardCVC)
                } else {
                    inputView?.textFieldCardExpDate.textColor = colorError
                }
            }
        } else if inputView?.textFieldCardCVC == textField {
            inputView?.textFieldCardExpDate.textColor = colorNormal
            inputCardCVC = value
        }

        inputAccessoryViewWithButton?.buttonAction.isEnabled = validateRequisites()
    }
}

extension InputCardRequisitesController: InputCardRequisitesDataSource {
    // MARK: InputCardRequisitesDataSource

    func setup(responderListener: BecomeFirstResponderListener?,
               inputView: InputRequisitesViewInConnection?,
               inputAccessoryView: InputAccessoryViewWithButton? = nil,
               scaner: CardRequisitesScanerProtocol? = nil) {
        becomeFirstResponderListener = responderListener
        self.inputView = inputView
        inputAccessoryViewWithButton = inputAccessoryView
        inputAccessoryViewWithButton?.onButtonTouchUpInside = { [weak self] in
            self?.onButtonDoneTouchUpInside()
        }

        cardRequisitesScaner = scaner

        maskedTextFieldCardNumberDelegate = MaskedTextFieldDelegate()
        maskedTextFieldCardNumberDelegate.maskFormat = maskFormat16
        maskedTextFieldCardNumberDelegate.listener = self
        self.inputView?.textFieldCardNumber.delegate = maskedTextFieldCardNumberDelegate
        self.inputView?.textFieldCardNumber.placeholder = placeholderCardNumber

        maskedTextFieldCardExpDateDelegate = MaskedTextFieldDelegate()
        maskedTextFieldCardExpDateDelegate.maskFormat = maskFormatDate
        maskedTextFieldCardExpDateDelegate.listener = self
        self.inputView?.textFieldCardExpDate.delegate = maskedTextFieldCardExpDateDelegate
        self.inputView?.textFieldCardExpDate.placeholder = placeholderCardExpDate

        maskedTextFieldCardCVCDelegate = MaskedTextFieldDelegate()
        maskedTextFieldCardCVCDelegate.maskFormat = maskFormatCVC
        maskedTextFieldCardCVCDelegate.listener = self
        self.inputView?.textFieldCardCVC.delegate = maskedTextFieldCardCVCDelegate
        self.inputView?.textFieldCardCVC.placeholder = placeholderCardCVC

        activateStep(.addRequisites)
    }

    func setupForCVC(responderListener: BecomeFirstResponderListener?, inputView: InputRequisitesViewInConnection?) {
        self.inputView = inputView
        cardRequisitesScaner = nil

        inputView?.textFieldCardCVC.delegate = maskedTextFieldCardCVCDelegate
        becomeFirstResponderListener = responderListener
        self.inputView?.textFieldCardCVC.delegate = maskedTextFieldCardCVCDelegate
        activateStep(.inputCardCVC)
    }

    func requisies() -> (number: String?, expDate: String?, cvc: String?) {
        return (inputCardNumber, inputCardExpDate, inputCardCVC)
    }
}
