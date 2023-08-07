//
//  AddNewCardPresenter.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 20.12.2022.
//

import Foundation
import enum TinkoffASDKCore.APIError

final class AddNewCardPresenter {
    // MARK: Dependencies

    weak var view: IAddNewCardView? {
        didSet { setupView() }
    }

    private let cardsController: ICardsController

    private let addCardOptions: AddCardOptions

    // MARK: Output Events Handlers

    private weak var output: IAddNewCardPresenterOutput?
    private var onViewWasClosed: ((AddCardResult) -> Void)?

    // MARK: Child presenters

    private let cardFieldPresenter: ICardFieldViewOutput

    // MARK: State

    private var moduleResult: AddCardResult = .cancelled

    // MARK: Init

    init(
        addCardOptions: AddCardOptions,
        cardsController: ICardsController,
        output: IAddNewCardPresenterOutput?,
        onViewWasClosed: ((AddCardResult) -> Void)?,
        cardFieldPresenter: ICardFieldViewOutput
    ) {
        self.addCardOptions = addCardOptions
        self.cardsController = cardsController
        self.output = output
        self.onViewWasClosed = onViewWasClosed
        self.cardFieldPresenter = cardFieldPresenter
    }
}

// MARK: - IAddNewCardPresenter

extension AddNewCardPresenter: IAddNewCardPresenter {
    func cardFieldViewAddCardTapped() {
        guard cardFieldPresenter.validateWholeForm().isValid else { return }

        let cardOptions = CardData(
            pan: cardFieldPresenter.cardNumber,
            validThru: cardFieldPresenter.expiration,
            cvc: cardFieldPresenter.cvc
        )

        addCard(options: cardOptions)
    }

    func viewDidLoad() {
        view?.reloadCollection(sections: [.cardField])
    }

    func viewDidAppear() {
        if view?.isLoading == false {
            view?.activateCardField()
        }
    }

    func viewWasClosed() {
        output?.addNewCardWasClosed(with: moduleResult)
        onViewWasClosed?(moduleResult)
        onViewWasClosed = nil
    }

    func cardFieldViewPresenter() -> ICardFieldViewOutput {
        cardFieldPresenter
    }
}

// MARK: - ICardFieldOutput

extension AddNewCardPresenter: ICardFieldOutput {
    func scanButtonPressed() {
        view?.showCardScanner { [weak self] cardNumber, expiration, cvc in
            self?.cardFieldPresenter.set(textFieldType: .cardNumber, text: cardNumber)
            self?.cardFieldPresenter.set(textFieldType: .expiration, text: expiration)
            self?.cardFieldPresenter.set(textFieldType: .cvc, text: cvc)
        }
    }

    func cardFieldValidationResultDidChange(result: CardFieldValidationResult) {
        view?.setAddButton(enabled: result.isValid)
    }
}

// MARK: - Private

extension AddNewCardPresenter {
    private func addCard(options: CardData) {
        view?.showLoadingState()

        cardsController.addCard(cardData: options) { [weak self] result in
            guard let self = self else { return }
            self.output?.addNewCardDidReceive(result: result)
            self.view?.hideLoadingState()
            self.moduleResult = result

            switch result {
            case .succeded:
                self.view?.closeScreen()
            case let .failed(error) where (error as NSError).code == 510:
                self.view?.showOkNativeAlert(data: .alreadyHasSuchCardError)
            case .failed:
                self.view?.showOkNativeAlert(data: .genericError)
            case .cancelled:
                self.view?.closeScreen()
            }
        }
    }

    private func setupView() {
        view?.setAddButton(enabled: false, animated: false)
    }
}

// MARK: - OkAlertData + Helpers

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
