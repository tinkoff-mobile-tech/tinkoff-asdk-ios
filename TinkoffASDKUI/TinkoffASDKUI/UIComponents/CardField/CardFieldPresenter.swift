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

protocol ICardFieldPresenter: AnyObject {
    var view: ICardFieldView? { get }
    var config: CardFieldView.Config? { get set }
    var validationResult: CardFieldPresenter.ValidationResult { get }

    func validateWholeForm() -> CardFieldPresenter.ValidationResult

    func didFillCardNumber(text: String, filled: Bool)
    func didFillExpiration(text: String, filled: Bool)
    func didFillCvc(text: String, filled: Bool)
}

final class CardFieldPresenter: ICardFieldPresenter {

    var config: CardFieldView.Config?
    private(set) weak var view: ICardFieldView?
    private(set) var validationResult: ValidationResult

    private var cardNumber: String = ""
    private var expiration: String = ""
    private var cvc: String = ""

    private var didStartEditingExpiration = false
    private var didEndEditingExpiration = false
    private var didStartEditingCvc = false
    private var didEndEditingCvc = false

    private let validator: ICardRequisitesValidator
    private let paymentSystemResolver: IPaymentSystemResolver
    private let bankResolver: IBankResolver

    init(
        view: ICardFieldView,
        config: CardFieldView.Config? = nil,
        validator: ICardRequisitesValidator = CardRequisitesValidator(),
        paymentSystemResolver: IPaymentSystemResolver = PaymentSystemResolver(),
        bankResolver: IBankResolver = BankResolver()

    ) {
        self.view = view
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
        if filled { view?.activateCvcField() }
    }

    func didFillCvc(text: String, filled: Bool) {
        cvc = text
        if filled { view?.deactivate() }
    }

    func validateWholeForm() -> ValidationResult {
        return validate(forced: true)
    }

    // MARK: - Private

    @discardableResult
    private func validate(forced: Bool = false) -> ValidationResult {
        let result = ValidationResult(
            cardNumberIsValid: validator.validate(inputPAN: cardNumber),
            expirationIsValid: validator.validate(inputValidThru: expiration),
            cvcIsValid: validator.validate(inputCVC: cvc)
        )
        validationResult = result

        print(result)
        updateTextfieldHeaderStyle(validationResult: result, forcedValidation: forced)
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
                    content: .plain(text: cardText, style: cardStyle.set(textColor: ASDKColors.red))
                )
            }

            if !result.expirationIsValid {
                expirationHeaderLabelConfig = UILabel.Configuration(
                    content: .plain(text: expText, style: expStyle.set(textColor: ASDKColors.red))
                )
            }

            if !result.cvcIsValid {
                cvcHeaderLabelConfig = UILabel.Configuration(
                    content: .plain(text: cvcText, style: cvcStyle.set(textColor: ASDKColors.red))
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
            switch event {
            case .didBeginEditing:
                self?.validate()
                self?.clearVisualErrorState(for: .cardNumber)
            case .didEndEditing:
                self?.validate()
            default: break
            }
        }

        config.expirationTextFieldConfig.textField.eventHandler = { [weak self] event, _ in
            switch event {
            case .didBeginEditing:
                self?.didStartEditingExpiration = true
                self?.validate()
                self?.clearVisualErrorState(for: .expiration)
            case .didEndEditing:
                self?.didEndEditingExpiration = true
                self?.validate()
            default: break
            }
        }

        config.cvcTextFieldConfig.textField.eventHandler = { [weak self] event, _ in
            switch event {
            case .didBeginEditing:
                self?.didStartEditingCvc = true
                self?.validate()
                self?.clearVisualErrorState(for: .cvc)
            case .didEndEditing:
                self?.didEndEditingCvc = true
                self?.validate()
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
    }

    enum Field: CaseIterable {
        case cardNumber
        case expiration
        case cvc
    }
}
