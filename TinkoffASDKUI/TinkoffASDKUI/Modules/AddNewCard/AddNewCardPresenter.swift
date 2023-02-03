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
    func viewDidAppear()
    func cardFieldViewAddCardTapped()
    func viewUserClosedTheScreen()

    func cardFieldViewPresenter() -> ICardFieldViewOutput
}

// MARK: - Presenter

final class AddNewCardPresenter {

    weak var view: IAddNewCardView?

    private let cardFieldPresenter = CardFieldPresenter()

    private weak var output: IAddNewCardOutput?
    private let networking: IAddNewCardNetworking

    private var didAddCard = false
    private var didReceviedError = false

    init(networking: IAddNewCardNetworking, output: IAddNewCardOutput?) {
        self.networking = networking
        self.output = output
        cardFieldPresenter.delegate = self
    }
}

extension AddNewCardPresenter: IAddNewCardPresenter {

    func cardFieldViewAddCardTapped() {
        guard cardFieldPresenter.validateWholeForm().isValid else { return }

        let cardData = CardData(cardNumber: cardFieldPresenter.cardNumber, expiration: cardFieldPresenter.expiration, cvc: cardFieldPresenter.cvc)
        addCard(cardData: cardData)
    }

    func viewDidLoad() {
        view?.reloadCollection(sections: [.cardField])
        view?.disableAddButton()
    }

    func viewDidAppear() {
        view?.activateCardField()
    }

    func viewUserClosedTheScreen() {
        // проверка что мы не сами закрываем экран после успешного добавления карты
        guard !didAddCard, !didReceviedError else { return }
        output?.addingNewCardCompleted(result: .cancelled)
    }

    func cardFieldViewPresenter() -> ICardFieldViewOutput {
        cardFieldPresenter
    }
}

extension AddNewCardPresenter: CardFieldDelegate {
    func cardFieldValidationResultDidChange(result: CardFieldValidationResult) {
        result.isValid ? view?.enableAddButton() : view?.disableAddButton()
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
                guard let self = self else { return }
                self.view?.hideLoadingState()

                switch result {
                case let .success(card):
                    self.view?.closeScreen()
                    self.didAddCard = true
                    self.output?.addingNewCardCompleted(result: .success(card: card))
                case let .failure(error):
                    self.didReceviedError = true
                    self.handleAddCard(error: error)
                case .cancelled:
                    self.view?.closeScreen()
                }
            }
        )
    }

    private func handleAddCard(error: Error) {
        let alreadyHasSuchCardErrorCode = 510

        if (error as NSError).code == alreadyHasSuchCardErrorCode {
            view?.showOkNativeAlert(data: .alreadyHasSuchCardError)
            output?.addingNewCardCompleted(result: .failure(error: error))
        } else {
            view?.showOkNativeAlert(data: .genericError)
            output?.addingNewCardCompleted(result: .failure(error: error))
        }
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
