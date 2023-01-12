//
//  AddNewCardViewController.swift
//  TinkoffASDKUI
//
//  Copyright (c) 2020 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import TinkoffASDKCore
import UIKit

enum AddNewCardSection {
    case cardField
}

public enum AddNewCardResult {
    case cancelled
    case success(card: PaymentCard)
    case failure(error: Error)
}

// MARK: - AddNewCardOutput

public protocol IAddNewCardOutput: AnyObject {
    func addingNewCardCompleted(result: AddNewCardResult)
}

// MARK: - AddNewCardView

protocol IAddNewCardView: AnyObject {
    func reloadCollection(sections: [AddNewCardSection])
    func showLoadingState()
    func hideLoadingState()
    func closeScreen()
    func disableAddButton()
    func enableAddButton()
    func showOkNativeAlert(data: OkAlertData)
}

// MARK: - AddNewCardViewController

final class AddNewCardViewController: UIViewController {

    private let presenter: IAddNewCardPresenter

    private lazy var addCardView = AddNewCardView(delegate: self, cardFieldFactory: cardFieldFactory)

    // Local State

    private weak var cardFieldView: ICardFieldView?
    private var didAddCard = false

    // Dependecies

    private let cardFieldFactory: ICardFieldFactory

    // MARK: - Inits

    init(
        presenter: IAddNewCardPresenter,
        cardFieldFactory: ICardFieldFactory
    ) {
        self.presenter = presenter
        self.cardFieldFactory = cardFieldFactory
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = addCardView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        presenter.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cardFieldView?.activate()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let isBeingDismissed = navigationController?.isBeingDismissed == true
        // Тречит дисмисс или свайп вью контроллера
        if isBeingDismissed || isMovingFromParent {
            presenter.viewUserClosedTheScreen()
        }
    }
}

// MARK: - IAddNewCardView

extension AddNewCardViewController: IAddNewCardView {

    func reloadCollection(sections: [AddNewCardSection]) {
        addCardView.reloadCollection(sections: sections)
    }

    func showLoadingState() {
        addCardView.showLoadingState()
    }

    func hideLoadingState() {
        addCardView.hideLoadingState()
    }

    func closeScreen() {
        let popedViewController = navigationController?.popViewController(animated: true)
        if popedViewController == nil {
            presentingViewController?.dismiss(animated: true)
        }
    }

    func showOkNativeAlert(data: OkAlertData) {
        let alert = UIAlertController.okAlert(data: data)
        present(alert, animated: true)
    }

    func disableAddButton() {
        addCardView.disableAddButton()
    }

    func enableAddButton() {
        addCardView.enableAddButton()
    }
}

// MARK: - Navigation Controller Setup

extension AddNewCardViewController {

    private func setupNavigationItem() {
        navigationItem.title = Loc.Acquiring.AddNewCard.screenTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: Loc.Acquiring.AddNewCard.buttonClose,
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
    }

    @objc private func closeButtonTapped() {
        closeScreen()
    }
}

// MARK: - AddNewCardViewDelegate

extension AddNewCardViewController: AddNewCardViewDelegate {

    func viewAddCardTapped(cardData: CardData) {
        presenter.viewAddCardTapped(cardData: cardData)
    }

    func cardFieldValidationResultDidChange(result: CardFieldValidationResult) {
        presenter.cardFieldValidationResultDidChange(result: result)
    }
}
