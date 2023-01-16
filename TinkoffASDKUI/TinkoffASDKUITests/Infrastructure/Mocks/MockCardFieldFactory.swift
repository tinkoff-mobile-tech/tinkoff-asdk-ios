//
//  MockCardFieldFactory.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 28.12.2022.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class MockCardFieldFactory: ICardFieldFactory {

    var assembleCardFieldConfigCallCounter = 0
    lazy var assembleCardFieldConfigStub: () -> CardFieldView = {
        let presenter = MockCardFieldPresenter()
        return CardFieldView(presenter: presenter)
    }

    func assembleCardFieldView() -> CardFieldView {
        assembleCardFieldConfigCallCounter += 1
        return assembleCardFieldConfigStub()
    }
}

extension MockCardFieldFactory {

    private func prepareFactoryResult() -> CardFieldFactory.FactoryResult {
        return .init(
            configuration:
            .assembleWithRegularStyle(
                data: CardFieldView.DataDependecies(
                    dynamicCardIconData: DynamicIconCardView.Data(),
                    expirationTextFieldData: CardFieldView.DataDependecies.TextFieldData(
                        delegate: nil, text: nil, placeholder: nil, headerText: ""
                    ),
                    cardNumberTextFieldData: CardFieldView.DataDependecies.TextFieldData(
                        delegate: nil, text: nil, placeholder: nil, headerText: ""
                    ),
                    cvcTextFieldData: CardFieldView.DataDependecies.TextFieldData(
                        delegate: nil, text: nil, placeholder: nil, headerText: ""
                    )
                )
            ),
            presenter: CardFieldPresenter(listenerStorage: [])
        )
    }
}
