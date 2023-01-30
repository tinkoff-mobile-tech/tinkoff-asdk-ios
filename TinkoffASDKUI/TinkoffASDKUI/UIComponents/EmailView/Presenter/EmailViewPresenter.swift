//
//  EmailViewPresenter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 27.01.2023.
//

import Foundation

final class EmailViewPresenter: IEmailViewOutput, IEmailViewPresenterInput {

    // MARK: Dependencies

    weak var view: IEmailViewInput? {
        didSet {
            setupView()
        }
    }

    private weak var output: IEmailViewPresenterOutput?

    // MARK: IEmailViewPresenterInput Properties

    let customerEmail: String
    private(set) lazy var currentEmail: String = customerEmail
    var isEmailValid: Bool { isValidEmail(currentEmail) }

    // MARK: Initialization

    init(
        customerEmail: String,
        output: IEmailViewPresenterOutput
    ) {
        self.customerEmail = customerEmail
        self.output = output
    }
}

// MARK: - IEmailViewOutput

extension EmailViewPresenter {
    func textFieldDidBeginEditing() {
        view?.setTextFieldHeaderNormal()
        output?.emailTextFieldDidBeginEditing(self)
    }

    func textFieldDidChangeText(to text: String) {
        guard text != currentEmail else { return }

        currentEmail = text
        output?.emailTextField(self, didChangeEmail: currentEmail, isValid: isEmailValid)
    }

    func textFieldDidEndEditing() {
        viewSetTextFieldHeaderState()
        output?.emailTextFieldDidEndEditing(self)
    }

    func textFieldDidPressReturn() {
        view?.hideKeyboard()
        output?.emailTextFieldDidPressReturn(self)
    }
}

// MARK: - Private

extension EmailViewPresenter {
    private func setupView() {
        viewSetTextFieldHeaderState()
        view?.setTextField(text: currentEmail)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = ".+\\@.+\\..+"

        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    private func viewSetTextFieldHeaderState() {
        isEmailValid ? view?.setTextFieldHeaderNormal() : view?.setTextFieldHeaderError()
    }
}
