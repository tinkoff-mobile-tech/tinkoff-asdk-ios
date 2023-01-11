//
//  CardFieldPresenter.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 29.11.2022.
//

import UIKit

protocol ICardFieldView: AnyObject, Activatable {
    func activateExpirationField()
    func activateCvcField()
}

struct CardData {
    let cardNumber: String
    let expiration: String
    let cvc: String
}

protocol ICardFieldInput: AnyObject {
    var cardNumber: String { get }
    var expiration: String { get }
    var cvc: String { get }

    var validationResult: CardFieldPresenter.ValidationResult { get }

    func validateWholeForm() -> CardFieldPresenter.ValidationResult
}

protocol ICardFieldPresenter: ICardFieldInput {
    var config: CardFieldView.Config? { get set }
    var validationResultDidChange: ((CardFieldPresenter.ValidationResult) -> Void)? { get set }

    func didFillCardNumber(text: String, filled: Bool)
    func didFillExpiration(text: String, filled: Bool)
    func didFillCvc(text: String, filled: Bool)
}

final class CardFieldPresenter: ICardFieldPresenter {

    var config: CardFieldView.Config?
    var validationResultDidChange: ((ValidationResult) -> Void)?

    weak var view: ICardFieldView?

    private(set) var validationResult: ValidationResult {
        didSet { validationResultDidChange?(validationResult) }
    }

    private(set) var cardNumber: String = ""
    private(set) var expiration: String = ""
    private(set) var cvc: String = ""

    private var didStartEditingExpiration = false
    private var didEndEditingExpiration = false
    private var didStartEditingCvc = false
    private var didEndEditingCvc = false

    private let validator: ICardRequisitesValidator
    private let paymentSystemResolver: IPaymentSystemResolver
    private let bankResolver: IBankResolver

    // Хранит listener-ы для masked text field delegate
    private var listenerStorage: [NSObject]

    init(
        listenerStorage: [NSObject],
        config: CardFieldView.Config? = nil,
        validator: ICardRequisitesValidator = CardRequisitesValidator(),
        paymentSystemResolver: IPaymentSystemResolver = PaymentSystemResolver(),
        bankResolver: IBankResolver = BankResolver()
    ) {
        self.listenerStorage = listenerStorage
        self.config = config
        self.validator = validator
        self.paymentSystemResolver = paymentSystemResolver
        self.bankResolver = bankResolver
        validationResult = ValidationResult()
        self.config?.onDidConfigure = { [weak self] in self?.didConfigureView() }
        setupEventHandlers()
    }

    func didFillCardNumber(text: String, filled: Bool) {
        cardNumber = text
        validate()

        let textFieldConfig = config?.cardNumberTextFieldConfig.textField
        (textFieldConfig?.rightAccessoryView?.content as? DeleteButtonContent)?
            .didChangeText(hasText: !text.isEmpty)

        let bankResult = bankResolver.resolve(cardNumber: text)
            .getBank()?
            .icon

        let paymentSystemResult = paymentSystemResolver.resolve(by: text)
            .getPaymentSystem()?
            .icon

        config?.dynamicCardIcon.data.bank = bankResult
        config?.dynamicCardIcon.data.paymentSystem = paymentSystemResult

        if let dynamicCardConfig = config?.dynamicCardIcon {
            config?.dynamicCardIcon.updater?.update(config: dynamicCardConfig)
        }

        if filled { view?.activateExpirationField() }
    }

    func didFillExpiration(text: String, filled: Bool) {
        expiration = text
        validate()

        let textFieldConfig = config?.expirationTextFieldConfig.textField
        (textFieldConfig?.rightAccessoryView?.content as? DeleteButtonContent)?
            .didChangeText(hasText: !text.isEmpty)

        if filled { view?.activateCvcField() }
    }

    func didFillCvc(text: String, filled: Bool) {
        cvc = text
        validate()

        let textFieldConfig = config?.cvcTextFieldConfig.textField
        (textFieldConfig?.rightAccessoryView?.content as? DeleteButtonContent)?
            .didChangeText(hasText: !text.isEmpty)

        if filled { view?.deactivate() }
    }

    func validateWholeForm() -> ValidationResult {
        let result = validate()
        updateTextfieldHeaderStyle(validationResult: result, forcedValidation: true)
        return result
    }

    // MARK: - Private

    @discardableResult
    private func validate() -> ValidationResult {
        let result = ValidationResult(
            cardNumberIsValid: validator.validate(inputPAN: cardNumber),
            expirationIsValid: validator.validate(inputValidThru: expiration),
            cvcIsValid: validator.validate(inputCVC: cvc)
        )
        validationResult = result
        return result
    }

    private func didConfigureView() {
        view?.activate()
    }

    private func updateTextfieldHeaderStyle(validationResult result: ValidationResult, forcedValidation: Bool) {
        guard let config = config else { return }

        var cardNumberHeaderLabelConfig = config.cardNumberTextFieldConfig.headerLabel
        var expirationHeaderLabelConfig = config.expirationTextFieldConfig.headerLabel
        var cvcHeaderLabelConfig = config.cvcTextFieldConfig.headerLabel

        switch (
            cardNumberHeaderLabelConfig.content,
            expirationHeaderLabelConfig.content,
            cvcHeaderLabelConfig.content
        ) {
        case let (
            .plain(cardText, cardStyle),
            .plain(expText, expStyle),
            .plain(cvcText, cvcStyle)
        ):
            if !result.cardNumberIsValid {
                cardNumberHeaderLabelConfig = UILabel.Configuration(
                    content: .plain(text: cardText, style: cardStyle.set(textColor: ASDKColors.Foreground.negativeAccent))
                )
            }

            if !result.expirationIsValid {
                expirationHeaderLabelConfig = UILabel.Configuration(
                    content: .plain(text: expText, style: expStyle.set(textColor: ASDKColors.Foreground.negativeAccent))
                )
            }

            if !result.cvcIsValid {
                cvcHeaderLabelConfig = UILabel.Configuration(
                    content: .plain(text: cvcText, style: cvcStyle.set(textColor: ASDKColors.Foreground.negativeAccent))
                )
            }

        default:
            break
        }

        let fields = fieldsToValidate(forced: forcedValidation)

        fields.forEach { field in
            switch field {
            case .cardNumber:
                config.cardNumberTextFieldConfig.updater?.updateHeader(config: cardNumberHeaderLabelConfig)
            case .expiration:
                config.expirationTextFieldConfig.updater?.updateHeader(config: expirationHeaderLabelConfig)
            case .cvc:
                config.cvcTextFieldConfig.updater?.updateHeader(config: cvcHeaderLabelConfig)
            }
        }
    }

    private func clearVisualErrorState(for field: Field) {
        guard let config = config else { return }

        switch field {
        case .cardNumber:
            let cardNumberConfig = config.cardNumberTextFieldConfig
            cardNumberConfig.updater?.updateHeader(config: cardNumberConfig.headerLabel)
        case .expiration:
            let expirationConfig = config.expirationTextFieldConfig
            expirationConfig.updater?.updateHeader(config: expirationConfig.headerLabel)
        case .cvc:
            let cvcConfig = config.cvcTextFieldConfig
            cvcConfig.updater?.updateHeader(config: cvcConfig.headerLabel)
        }
    }

    private func setupEventHandlers() {
        guard let config = config else { return }

        config.cardNumberTextFieldConfig.textField.eventHandler = { [weak self] event, _ in
            guard let self = self else { return }
            switch event {
            case .didBeginEditing:
                let result = self.validate()
                self.updateTextfieldHeaderStyle(
                    validationResult: result,
                    forcedValidation: false
                )
                self.clearVisualErrorState(for: .cardNumber)
            case .didEndEditing:
                self.validate()
            default: break
            }
        }

        config.expirationTextFieldConfig.textField.eventHandler = { [weak self] event, _ in
            guard let self = self else { return }
            switch event {
            case .didBeginEditing:
                self.didStartEditingExpiration = true
                let result = self.validate()
                self.updateTextfieldHeaderStyle(
                    validationResult: result,
                    forcedValidation: false
                )
                self.clearVisualErrorState(for: .expiration)
            case .didEndEditing:
                self.didEndEditingExpiration = true
                self.validate()
            default: break
            }
        }

        config.cvcTextFieldConfig.textField.eventHandler = { [weak self] event, _ in
            guard let self = self else { return }
            switch event {
            case .didBeginEditing:
                self.didStartEditingCvc = true
                let result = self.validate()
                self.updateTextfieldHeaderStyle(
                    validationResult: result,
                    forcedValidation: false
                )
                self.clearVisualErrorState(for: .cvc)
            case .didEndEditing:
                self.didEndEditingCvc = true
                self.validate()
            default: break
            }
        }
    }

    private func fieldsToValidate(forced: Bool) -> [Field] {
        if forced {
            return Field.allCases
        }

        if didEndEditingCvc {
            return Field.allCases
        }

        if didStartEditingCvc || didEndEditingExpiration {
            return [.cardNumber, .expiration]
        }

        if didStartEditingExpiration {
            return [.cardNumber]
        }

        return []
    }
}

extension CardFieldPresenter {

    struct ValidationResult {
        var cardNumberIsValid = false
        var expirationIsValid = false
        var cvcIsValid = false

        var isValid: Bool { cardNumberIsValid && expirationIsValid && cvcIsValid }
    }

    enum Field: CaseIterable {
        case cardNumber
        case expiration
        case cvc
    }
}
