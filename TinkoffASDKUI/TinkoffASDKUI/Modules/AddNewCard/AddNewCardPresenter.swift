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
    func viewAddCardTapped(cardData: CardData)
    func viewUserClosedTheScreen()
    func cardFieldValidationResultDidChange(result: CardFieldValidationResult)
}

// MARK: - Presenter

final class AddNewCardPresenter {

    weak var view: IAddNewCardView?

    private weak var output: IAddNewCardOutput?
    private let networking: IAddNewCardNetworking

    private var didAddCard = false

    init(networking: IAddNewCardNetworking, output: IAddNewCardOutput?) {
        self.networking = networking
        self.output = output
    }
}

extension AddNewCardPresenter: IAddNewCardPresenter {

    func viewAddCardTapped(cardData: CardData) {
        addCard(cardData: cardData)
    }

    func viewDidLoad() {
        view?.reloadCollection(sections: [.cardField])
        view?.disableAddButton()
    }

    func viewUserClosedTheScreen() {
        // проверка что мы не сами закрываем экран после успешного добавления карты
        guard !didAddCard else { return }
        output?.addingNewCardCompleted(result: .cancelled)
    }

    func cardFieldValidationResultDidChange(result: CardFieldValidationResult) {
        if result.isValid {
            view?.enableAddButton()
        } else {
            view?.disableAddButton()
        }
    }
}

// MARK: - Private

extension AddNewCardPresenter {

    private func addCard(cardData: CardData) {
        view?.showLoadingState()
        networking.addCard(
            number: cardData.cardNumber,
            expiration: cardData.expiration,
            cvc: cardData.cvc,
            resultCompletion: { [weak self] result in
                guard let self = self
                else { return }

                self.view?.hideLoadingState()

                switch result {
                case let .success(card):
                    self.view?.closeScreen()
                    self.didAddCard = true
                    self.output?.addingNewCardCompleted(result: .success(card: card))
                case let .failure(error):
                    self.handleAddCard(error: error)
                }
            }
        )
    }

    private func handleAddCard(error: Error) {
        let alreadyHasSuchCardErrorCode = 510

        if case AcquiringUiSdkError.userCancelledCardAdding = error {
            view?.closeScreen()
        } else if (error as NSError).code == alreadyHasSuchCardErrorCode {
            view?.showOkNativeAlert(data: .alreadyHasSuchCardError)
        } else {
            view?.showOkNativeAlert(data: .genericError)
        }

        output?.addingNewCardCompleted(result: .failure(error: error))
    }
}

private extension OkAlertData {

    static var alreadyHasSuchCardError: Self {
        OkAlertData(
            title: Loc.CommonAlert.AddCard.title,
            buttonTitle: Loc.CommonAlert.button
        )
    }

    static var genericError: Self {
        OkAlertData(
            title: Loc.CommonAlert.SomeProblem.title,
            message: Loc.CommonAlert.SomeProblem.description,
            buttonTitle: Loc.CommonAlert.button
        )
    }
}
