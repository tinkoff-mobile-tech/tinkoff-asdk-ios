//
//  EmailView.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 27.01.2023.
//

import UIKit

typealias EmailTableCell = TableCell<EmailView>

final class EmailView: UIView, IEmailViewInput {

    // MARK: Dependencies

    var presenter: IEmailViewOutput? {
        didSet {
            if oldValue?.view === self { oldValue?.view = nil }
            presenter?.view = self
        }
    }

    // MARK: Properties

    private lazy var textField = FloatingTextField()

    // MARK: Initialization

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupViews()
        setupViewsConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - IEmailViewInput

extension EmailView {
    func setTextFieldHeaderError() {
        textField.setHeader(color: ASDKColors.Foreground.negativeAccent)
    }

    func setTextFieldHeaderNormal() {
        textField.setHeader(color: ASDKColors.Text.secondary.color)
    }

    func setTextField(text: String) {
        textField.set(text: text)
    }

    func hideKeyboard() {
        endEditing(true)
    }
}

// MARK: - FloatingTextFieldDelegate

extension EmailView: FloatingTextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        presenter?.textFieldDidBeginEditing()
    }

    func textField(_ textField: UITextField, didChangeTextTo newText: String) {
        presenter?.textFieldDidChangeText(to: newText)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        presenter?.textFieldDidEndEditing()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        presenter?.textFieldDidPressReturn()
        return true
    }
}

// MARK: - Private

extension EmailView {
    private func setupViews() {
        backgroundColor = .clear

        addSubview(textField)
        textField.delegate = self

        textField.setHeader(text: Loc.Acquiring.EmailField.title)
        textField.set(contentType: .emailAddress)
        textField.set(keyboardType: .emailAddress)
    }

    private func setupViewsConstraints() {
        textField.pinEdgesToSuperview()
        heightAnchor.constraint(greaterThanOrEqualToConstant: .minimalHeight).isActive = true
    }
}

// MARK: - Constants

private extension CGFloat {
    static let minimalHeight: CGFloat = 56
}
