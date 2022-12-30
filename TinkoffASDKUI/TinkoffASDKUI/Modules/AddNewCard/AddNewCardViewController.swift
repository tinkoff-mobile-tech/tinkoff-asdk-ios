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
    case cardField(configs: [CardFieldView.Configuration])
}

// MARK: - AddNewCardOutput

public protocol IAddNewCardOutput: AnyObject {
    func addNewCardDidTapCloseButton()
    func addNewCardDidAddCard(paymentCard: PaymentCard)
}

// MARK: - AddNewCardView

protocol IAddNewCardView: AnyObject {
    func reloadCollection(sections: [AddNewCardSection])
    func showLoadingState()
    func hideLoadingState()
    func notifyAdded(card: PaymentCard)
    func closeScreen()
    func showAlreadySuchCardErrorNativeAlert()
    func showGenericErrorNativeAlert()
    func disableAddButton()
    func enableAddButton()
}

// MARK: - AddNewCardViewController

final class AddNewCardViewController: UIViewController {

    private weak var output: IAddNewCardOutput?
    private let presenter: IAddNewCardPresenter

    private lazy var addCardView = AddNewCardView(delegate: self)

    // Local State

    private weak var cardFieldView: ICardFieldView?

    // MARK: - Inits

    init(
        output: IAddNewCardOutput?,
        presenter: IAddNewCardPresenter
    ) {
        self.output = output
        self.presenter = presenter
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

    func notifyAdded(card: PaymentCard) {
        output?.addNewCardDidAddCard(paymentCard: card)
    }

    func closeScreen() {
        navigationController?.popViewController(animated: true)
    }

    func showGenericErrorNativeAlert() {
        let alertViewController = UIAlertController.okAlert(
            title: Loc.CommonAlert.SomeProblem.title,
            message: Loc.CommonAlert.SomeProblem.description,
            buttonTitle: Loc.CommonAlert.button
        )

        present(alertViewController, animated: true)
    }

    func showAlreadySuchCardErrorNativeAlert() {
        let alertViewController = UIAlertController.okAlert(
            title: Loc.CommonAlert.AddCard.title,
            message: nil,
            buttonTitle: Loc.CommonAlert.button
        )

        present(alertViewController, animated: true)
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
        output?.addNewCardDidTapCloseButton()
    }
}

// MARK: - AddNewCardViewDelegate

extension AddNewCardViewController: AddNewCardViewDelegate {

    func viewAddCardTapped() {
        presenter.viewAddCardTapped()
    }

    func viewDidReceiveCardFieldView(cardFieldView: ICardFieldView) {
        self.cardFieldView = cardFieldView
        presenter.viewDidReceiveCardFieldView(cardFieldView: cardFieldView)
    }
}
