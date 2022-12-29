//
//  StubMode.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 13.12.2022.
//

import Foundation

enum StubMode {
    private typealias Data = BaseStubViewBuilder.InputData

    case noNetwork(buttonAction: () -> Void)
    case noCards(buttonAction: () -> Void)
    case serverError(buttonAction: () -> Void)

    func convertToInfoInputData() -> BaseStubViewBuilder.InputData {
        typealias Texts = Loc.CommonStub

        switch self {
        case let .noNetwork(action):
            return Data(
                icon: Asset.Illustrations.wiFiOff.image,
                title: Texts.NoNetwork.title,
                subtitle: Texts.NoNetwork.description,
                buttonTitle: Texts.NoNetwork.button,
                buttonAction: action
            )
        case let .noCards(action):
            return Data(
                icon: Asset.Illustrations.cardCross.image,
                title: "",
                subtitle: Texts.NoCards.description,
                buttonTitle: Texts.NoCards.button,
                buttonAction: action
            )
        case let .serverError(action):
            return Data(
                icon: Asset.Illustrations.alarm.image,
                title: Texts.SomeProblem.title,
                subtitle: Texts.SomeProblem.description,
                buttonTitle: Texts.SomeProblem.button,
                buttonAction: action
            )
        }
    }
}
