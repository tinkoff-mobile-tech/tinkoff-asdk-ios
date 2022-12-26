//
//  CardFieldFactory.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 30.11.2022.
//

import Foundation

protocol ICardFieldFactory {

    /// Собирает конфиг и настраивает логические связи / обработку событий
    func assembleCardFieldConfig(getCardFieldView: @escaping () -> ICardFieldView?) -> CardFieldFactory.FactoryResult
}

final class CardFieldFactory: ICardFieldFactory {

    struct FactoryResult {
        let configuration: CardFieldView.Configuration
        let presenter: ICardFieldPresenter
    }

    typealias Texts = Loc.Acquiring.CardField
    private let maskingFactory: ICardFieldMaskingFactory = CardFieldMaskingFactory()

    /// Собирает конфиг и настраивает логические связи / обработку событий
    func assembleCardFieldConfig(getCardFieldView: @escaping () -> ICardFieldView?) -> FactoryResult {
        var cardFieldPresenter: ICardFieldPresenter!
        var listenerStorage: [NSObject] = []

        let cardViewModel = DynamicIconCardView.Model(
            data: DynamicIconCardView.Data()
        )

        let expData = CardFieldView.DataDependecies.TextFieldData(
            delegate: maskingFactory.buildForExpiration(didFillMask: { text, completed in
                cardFieldPresenter.didFillExpiration(text: text, filled: completed)
            }, listenerStorage: &listenerStorage),
            text: nil,
            placeholder: Texts.termPlaceholder,
            headerText: Texts.termTitle
        )

        let cardNumberData = CardFieldView.DataDependecies.TextFieldData(
            delegate: maskingFactory.buildForCardNumber(didFillMask: { text, completed in
                cardFieldPresenter.didFillCardNumber(text: text, filled: completed)
            }, listenerStorage: &listenerStorage),
            text: nil,
            placeholder: nil,
            headerText: Texts.panTitle
        )

        let cvcData = CardFieldView.DataDependecies.TextFieldData(
            delegate: maskingFactory.buildForCvc(didFillMask: { text, completed in
                cardFieldPresenter.didFillCvc(text: text, filled: completed)
            }, listenerStorage: &listenerStorage),
            text: nil,
            placeholder: Texts.cvvPlaceholder,
            headerText: Texts.cvvTitle
        )

        let config = CardFieldView.Config.assembleWithRegularStyle(
            data: CardFieldView.DataDependecies(
                dynamicCardIconData: cardViewModel.data,
                expirationTextFieldData: expData,
                cardNumberTextFieldData: cardNumberData,
                cvcTextFieldData: cvcData
            )
        )

        cardFieldPresenter = CardFieldPresenter(
            getCardFieldView: getCardFieldView,
            listenerStorage: listenerStorage,
            config: config
        )
        return FactoryResult(configuration: config, presenter: cardFieldPresenter)
    }
}
