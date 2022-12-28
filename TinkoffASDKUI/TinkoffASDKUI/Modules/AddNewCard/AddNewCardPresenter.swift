//
//  AddNewCardPresenter.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 20.12.2022.
//

import Foundation
import enum TinkoffASDKCore.APIError

protocol IAddNewCardPresenter: AnyObject {

    func viewDidLoad()
    func viewAddCardTapped()
    func viewDidReceiveCardFieldView(cardFieldView: ICardFieldView)
}

// MARK: - Presenter

final class AddNewCardPresenter {

    weak var view: IAddNewCardView?

    private let cardFieldFactory: ICardFieldFactory
    private let networking: IAddNewCardNetworking

    private var cardFieldView: ICardFieldView?
    private var cardfieldFactoryResult: CardFieldFactory.FactoryResult?

    init(cardFieldFactory: ICardFieldFactory, networking: IAddNewCardNetworking) {
        self.cardFieldFactory = cardFieldFactory
        self.networking = networking
    }
}

extension AddNewCardPresenter: IAddNewCardPresenter {

    func viewAddCardTapped() {
        addCard()
    }

    func viewDidLoad() {
        view?.reloadCollection(
            sections: [.cardField(configs: [getCardFieldConfig().configuration])]
        )
        view?.disableAddButton()
    }

    func viewDidReceiveCardFieldView(cardFieldView: ICardFieldView) {
        self.cardFieldView = cardFieldView
    }
}

// MARK: - Private

extension AddNewCardPresenter {

    private func getCardFieldConfig() -> CardFieldFactory.FactoryResult {
        let result = cardFieldFactory.assembleCardFieldConfig(
            getCardFieldView: { [weak self] in
                self?.cardFieldView
            }
        )

        cardfieldFactoryResult = result
        cardfieldFactoryResult?.presenter.validationResultDidChange = { [weak self] validationResult in
            if validationResult.isValid {
                self?.view?.enableAddButton()
            } else {
                self?.view?.disableAddButton()
            }
        }
        return result
    }

    private func addCard() {
        guard canStartAddingCard(),
              let cardfieldPresenter = cardfieldFactoryResult?.presenter
        else { return }

        view?.showLoadingState()
        networking.addCard(
            number: cardfieldPresenter.cardNumber,
            expiration: cardfieldPresenter.expiration,
            cvc: cardfieldPresenter.cvc,
            resultCompletion: { [weak self] result in
                guard let self = self
                else { return }

                self.view?.hideLoadingState()

                switch result {
                case let .success(card):
                    self.view?.closeScreen()
                    self.view?.notifyAdded(card: card)
                case let .failure(error):
                    self.handleAddCard(error: error)
                }
            }
        )
    }

    private func canStartAddingCard() -> Bool {
        guard let cardFieldPresenter = cardfieldFactoryResult?.presenter
        else { return false }
        let formIsValid = cardFieldPresenter.validateWholeForm().isValid
        return formIsValid
    }

    private func handleAddCard(error: Error) {
        let alreadyHasSuchCardErrorCode = 510

        if case AcquiringUiSdkError.userCancelledCardAdding = error {
            view?.closeScreen()
        } else if let apiError = error as? APIError, apiError.errorCode == alreadyHasSuchCardErrorCode {
            view?.showAlreadySuchCardErrorNativeAlert()
        } else {
            view?.showGenericErrorNativeAlert()
        }
    }
}
