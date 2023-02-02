//
//  CardFieldFactory.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 30.11.2022.
//

import Foundation

protocol ICardFieldFactory {

    /// Собирает CardFieldView конфигурирует и настраивает логические связи / обработку событий
    func assembleCardFieldView() -> CardFieldView
}

final class CardFieldFactory: ICardFieldFactory {

    struct FactoryResult {
        let configuration: CardFieldView.Configuration
        let presenter: ICardFieldPresenter
    }

    typealias Texts = Loc.Acquiring.CardField
    private let maskingFactory: ICardFieldMaskingFactory = CardFieldMaskingFactory()

    /// Собирает конфиг и настраивает логические связи / обработку событий
    func assembleCardFieldView() -> CardFieldView {
        var cardFieldPresenter: ICardFieldPresenter!
        var listenerStorage: [NSObject] = []

        let cardViewModel = DynamicIconCardView.Model(data: DynamicIconCardView.Data())

        let cardNumberDelegate = maskingFactory.buildForCardNumber(didFillMask: { text, completed in
            cardFieldPresenter.didFillCardNumber(text: text, filled: completed)
        }, didBeginEditing: {
            cardFieldPresenter.didBeginEditing(fieldType: .cardNumber)
        }, didEndEditing: {
            cardFieldPresenter.didEndEditing(fieldType: .cardNumber)
        }, listenerStorage: &listenerStorage)

        let expDelegate = maskingFactory.buildForExpiration(didFillMask: { text, completed in
            cardFieldPresenter.didFillExpiration(text: text, filled: completed)
        }, didBeginEditing: {
            cardFieldPresenter.didBeginEditing(fieldType: .expiration)
        }, didEndEditing: {
            cardFieldPresenter.didEndEditing(fieldType: .expiration)
        }, listenerStorage: &listenerStorage)

        let cvcDelegate = maskingFactory.buildForCvc(didFillMask: { text, completed in
            cardFieldPresenter.didFillCvc(text: text, filled: completed)
        }, didBeginEditing: {
            cardFieldPresenter.didBeginEditing(fieldType: .cvc)
        }, didEndEditing: {
            cardFieldPresenter.didEndEditing(fieldType: .cvc)
        }, listenerStorage: &listenerStorage)

        let config = CardFieldView.Config(
            dynamicCardIcon: cardViewModel,
            expirationFieldDelegate: expDelegate,
            cardNumberFieldDelegate: cardNumberDelegate,
            cvcFieldDelegate: cvcDelegate
        )

        let presenter = CardFieldPresenter(
            listenerStorage: listenerStorage,
            config: config
        )

        cardFieldPresenter = presenter
        let view = CardFieldView(presenter: cardFieldPresenter)
        presenter.view = view

        cardFieldPresenter.validationResultDidChange = { [weak view] result in
            view?.delegate?.cardFieldValidationResultDidChange(result: result)
        }

        view.update(with: config)
        return view
    }
}
