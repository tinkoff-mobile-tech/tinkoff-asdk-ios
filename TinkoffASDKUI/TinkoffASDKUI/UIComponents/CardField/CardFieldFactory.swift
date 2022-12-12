//
//  CardFieldFactory.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 30.11.2022.
//

import Foundation

final class CardFieldFactory {

    typealias Texts = Loc.Acquiring.CardField
    private let maskingFactory: ICardFieldMaskingFactory = CardFieldMaskingFactory()
    private var cardFieldPresenter: ICardFieldPresenter!

    /// Собирает конфиг и настраивает логические связи / обработку событий
    func assembleCardFieldConfig(view: ICardFieldView) -> CardFieldView.Configuration {
        let cardViewModel = DynamicIconCardView.Model(
            data: DynamicIconCardView.Data()
        )

        let expData = CardFieldView.DataDependecies.TextFieldData(
            delegate: maskingFactory.buildForExpiration(didFillMask: { [weak self] text, completed in
                guard let self = self else { return }
                self.cardFieldPresenter.didFillExpiration(text: text, filled: completed)
            }),
            text: nil,
            placeholder: Texts.termPlaceholder,
            headerText: Texts.termTitle
        )

        let cardNumberData = CardFieldView.DataDependecies.TextFieldData(
            delegate: maskingFactory.buildForCardNumber(didFillMask: { [weak self] text, completed in
                guard let self = self else { return }
                self.cardFieldPresenter.didFillCardNumber(text: text, filled: completed)
            }),
            text: nil,
            placeholder: nil,
            headerText: Texts.panTitle
        )

        let cvcData = CardFieldView.DataDependecies.TextFieldData(
            delegate: maskingFactory.buildForCvc(didFillMask: { [weak self] text, completed in
                guard let self = self else { return }
                self.cardFieldPresenter.didFillCvc(text: text, filled: completed)
            }),
            text: nil,
            placeholder: Texts.cvvPlaceholder,
            headerText: Texts.cvvTitle
        )

        let config = CardFieldView.Config.assembleWithRegularStyle(
            data: CardFieldView.DataDependecies(
                cardFieldData: CardFieldView.Data(),
                dynamicCardIconData: cardViewModel.data,
                expirationTextFieldData: expData,
                cardNumberTextFieldData: cardNumberData,
                cvcTextFieldData: cvcData
            )
        )

        cardFieldPresenter = CardFieldPresenter(view: view, config: config)
        return config
    }
}
