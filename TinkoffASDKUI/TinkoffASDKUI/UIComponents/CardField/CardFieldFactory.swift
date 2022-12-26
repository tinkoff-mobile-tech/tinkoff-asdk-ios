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

        var listenerStorage: [NSObject] = []

        let expData = CardFieldView.DataDependecies.TextFieldData(
            delegate: maskingFactory.buildForExpiration(didFillMask: { [weak self] text, completed in
                guard let self = self else { return }
                self.cardFieldPresenter.didFillExpiration(text: text, filled: completed)
            }, listenerStorage: &listenerStorage),
            text: nil,
            placeholder: Texts.termPlaceholder,
            headerText: Texts.termTitle
        )

        let cardNumberData = CardFieldView.DataDependecies.TextFieldData(
            delegate: maskingFactory.buildForCardNumber(didFillMask: { [weak self] text, completed in
                guard let self = self else { return }
                self.cardFieldPresenter.didFillCardNumber(text: text, filled: completed)
            }, listenerStorage: &listenerStorage),
            text: nil,
            placeholder: nil,
            headerText: Texts.panTitle
        )

        let cvcData = CardFieldView.DataDependecies.TextFieldData(
            delegate: maskingFactory.buildForCvc(didFillMask: { [weak self] text, completed in
                guard let self = self else { return }
                self.cardFieldPresenter.didFillCvc(text: text, filled: completed)
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
            config: config
        )
        return FactoryResult(configuration: config, presenter: cardFieldPresenter)
    }
}
