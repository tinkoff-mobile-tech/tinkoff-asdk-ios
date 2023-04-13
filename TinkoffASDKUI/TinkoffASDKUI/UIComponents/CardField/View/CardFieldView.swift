//
//  CardFieldView.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 03.02.2023.
//

import UIKit

typealias CardFieldTableCell = TableCell<CardFieldView>

final class CardFieldView: UIView, ICardFieldViewInput {

    // MARK: Dependencies

    var presenter: ICardFieldViewOutput? {
        didSet {
            if oldValue?.view === self { oldValue?.view = nil }
            presenter?.view = self
        }
    }

    private lazy var maskingFactory = CardFieldMaskingFactory()

    private lazy var cardNumberDelegate = maskingFactory.buildMaskingDelegate(for: .cardNumber, listener: self)
    private lazy var expirationDelegate = maskingFactory.buildMaskingDelegate(for: .expiration, listener: self)
    private lazy var cvcDelegate = maskingFactory.buildMaskingDelegate(for: .cvc, listener: self)

    // MARK: Properties

    private lazy var contentView = UIView()

    private lazy var dynamicCardView = DynamicIconCardView()

    private lazy var cardNumberTextField = FloatingTextField(insetsType: .commonAndHugeLeftInset)
    private lazy var expireTextField = FloatingTextField()
    private lazy var cvcTextField = FloatingTextField()

    private lazy var scanButton: UIButton = {
        let button = UIButton()
        button.setImage(Asset.scanCard.image, for: .normal)
        button.addTarget(self, action: #selector(scanButtonAction(_:)), for: .touchUpInside)
        return button
    }()

    // MARK: Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ICardFieldViewInput

extension CardFieldView {
    func updateDynamicCardView(with model: DynamicIconCardView.Model) {
        dynamicCardView.configure(model: model)
    }

    func updateCardNumberField(with maskFormat: String) -> Bool {
        cardNumberDelegate.update(maskFormat: maskFormat, using: cardNumberTextField.textField)
    }

    func activateScanButton() {
        cardNumberTextField.set(rightView: scanButton)
    }

    func setCardNumberTextField(rightViewMode: UITextField.ViewMode) {
        cardNumberTextField.set(rightViewMode: rightViewMode)
    }

    func set(textFieldType: CardFieldType, text: String?) {
        let floatingTextField = getTextField(for: textFieldType)
        floatingTextField.set(text: text)
        getTextFieldDelegate(for: textFieldType).put(text: text ?? "", into: floatingTextField.textField)
    }

    func setHeaderErrorFor(textFieldType: CardFieldType) {
        getTextField(for: textFieldType).setHeader(color: ASDKColors.Foreground.negativeAccent)
    }

    func setHeaderNormalFor(textFieldType: CardFieldType) {
        getTextField(for: textFieldType).setHeader(color: ASDKColors.Text.secondary.color)
    }

    func activate(textFieldType: CardFieldType) {
        getTextField(for: textFieldType).becomeFirstResponder()
    }

    func deactivate() {
        cardNumberTextField.resignFirstResponder()
        expireTextField.resignFirstResponder()
        cvcTextField.resignFirstResponder()
    }
}

// MARK: - MaskedTextFieldDelegateListener

extension CardFieldView: MaskedTextFieldDelegateListener {
    func textField(_ textField: UITextField, didFillMask complete: Bool, extractValue value: String) {
        guard let fieldType = getTextFieldType(textField: textField) else { return }
        presenter?.didFillField(type: fieldType, text: value, filled: complete)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let fieldType = getTextFieldType(textField: textField) else { return }
        presenter?.didBeginEditing(fieldType: fieldType)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let fieldType = getTextFieldType(textField: textField) else { return }
        presenter?.didEndEditing(fieldType: fieldType)
    }
}

// MARK: - Actions

extension CardFieldView {
    @objc private func scanButtonAction(_ sender: UIButton) {
        presenter?.scanButtonPressed()
    }
}

// MARK: - Private

extension CardFieldView {
    private func setupViews() {
        contentView.backgroundColor = .clear
        addSubview(contentView)

        contentView.addSubview(cardNumberTextField)
        contentView.addSubview(dynamicCardView)
        contentView.addSubview(expireTextField)
        contentView.addSubview(cvcTextField)

        cardNumberTextField.delegate = cardNumberDelegate
        cardNumberTextField.setHeader(text: Loc.Acquiring.CardField.panTitle)
        cardNumberTextField.set(contentType: .username)
        cardNumberTextField.set(keyboardType: .numberPad)

        expireTextField.delegate = expirationDelegate
        expireTextField.setHeader(text: Loc.Acquiring.CardField.termTitle)
        expireTextField.set(placeholder: Loc.Acquiring.CardField.termPlaceholder)
        expireTextField.set(contentType: .username)
        expireTextField.set(keyboardType: .asciiCapableNumberPad)

        cvcTextField.delegate = cvcDelegate
        cvcTextField.setHeader(text: Loc.Acquiring.CardField.cvvTitle)
        cvcTextField.set(placeholder: Loc.Acquiring.CardField.cvvPlaceholder)
        cvcTextField.set(contentType: .creditCardNumber)
        cvcTextField.set(keyboardType: .asciiCapableNumberPad)
        cvcTextField.set(isSecureTextEntry: true)
    }

    private func setupConstraints() {
        contentView.makeEqualToSuperview()

        cardNumberTextField.translatesAutoresizingMaskIntoConstraints = false
        dynamicCardView.translatesAutoresizingMaskIntoConstraints = false
        expireTextField.translatesAutoresizingMaskIntoConstraints = false
        cvcTextField.translatesAutoresizingMaskIntoConstraints = false
        scanButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cardNumberTextField.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            cardNumberTextField.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardNumberTextField.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            cardNumberTextField.heightAnchor.constraint(equalToConstant: .textFieldHeight),

            dynamicCardView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: .dynamicIconLeftInset),
            dynamicCardView.centerYAnchor.constraint(equalTo: cardNumberTextField.centerYAnchor),
            dynamicCardView.heightAnchor.constraint(equalToConstant: .dynamicIconHeight),
            dynamicCardView.widthAnchor.constraint(equalToConstant: .dynamicIconWidth),

            expireTextField.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            expireTextField.topAnchor.constraint(equalTo: cardNumberTextField.bottomAnchor, constant: .bottomFieldsTopInset),
            expireTextField.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            expireTextField.heightAnchor.constraint(equalToConstant: .textFieldHeight),
            expireTextField.widthAnchor.constraint(equalTo: cvcTextField.widthAnchor),

            cvcTextField.leftAnchor.constraint(equalTo: expireTextField.rightAnchor, constant: .cvcFieldLeftInset),
            cvcTextField.topAnchor.constraint(equalTo: cardNumberTextField.bottomAnchor, constant: .bottomFieldsTopInset),
            cvcTextField.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            cvcTextField.heightAnchor.constraint(equalTo: expireTextField.heightAnchor),

            scanButton.heightAnchor.constraint(equalToConstant: .textFieldHeight),
            scanButton.widthAnchor.constraint(equalToConstant: .scanButtonWidth),
        ])
    }

    private func getTextField(for type: CardFieldType) -> FloatingTextField {
        switch type {
        case .cardNumber: return cardNumberTextField
        case .expiration: return expireTextField
        case .cvc: return cvcTextField
        }
    }

    private func getTextFieldDelegate(for type: CardFieldType) -> MaskedTextFieldDelegate {
        switch type {
        case .cardNumber: return cardNumberDelegate
        case .expiration: return expirationDelegate
        case .cvc: return cvcDelegate
        }
    }

    private func getTextFieldType(textField: UITextField) -> CardFieldType? {
        switch textField {
        case cardNumberTextField.textField: return .cardNumber
        case expireTextField.textField: return .expiration
        case cvcTextField.textField: return .cvc
        default: return nil
        }
    }
}

// MARK: - Constants

private extension CGFloat {
    static let textFieldHeight: CGFloat = 56

    static let dynamicIconLeftInset: CGFloat = 12
    static let dynamicIconWidth: CGFloat = 40
    static let dynamicIconHeight: CGFloat = 26

    static let bottomFieldsTopInset: CGFloat = 12

    static let cvcFieldLeftInset: CGFloat = 11

    static let scanButtonWidth: CGFloat = 40
}
