//
//
//  CardListViewController.swift
//
//  Copyright (c) 2021 Tinkoff Bank
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


import UIKit

protocol ICardListViewInput: AnyObject {
    func reload(cards: [CardList.Card])
    func remove(card: CardList.Card)
    func show(alert: CardList.Alert)
    func showLoader()
    func hideLoader()
}

final class CardListViewController: UIViewController {
    // MARK: Dependencies

    private let style: CardListView.Style
    private let presenter: ICardListViewOutput
    private weak var externalAlertsFactory: AcquiringAlertViewProtocol?

    // MARK: Views

    private lazy var cardListView = CardListView(style: style, delegate: self)

    // MARK: Init

    init(
        style: CardListView.Style,
        presenter: ICardListViewOutput,
        externalAlertsFactory: AcquiringAlertViewProtocol?
    ) {
        self.style = style
        self.presenter = presenter
        self.externalAlertsFactory = externalAlertsFactory
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life Cycle

    override func loadView() {
        view = cardListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        presenter.viewDidLoad()
    }

    // MARK: Initial Configuration

    private func setupNavigationItem() {
        title = L10n.CardList.title
        navigationItem.largeTitleDisplayMode = .never

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: L10n.TinkoffAcquiring.Button.close,
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
    }

    // MARK: Actions

    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}

// MARK: - ICardListViewController

extension CardListViewController: ICardListViewInput {
    func reload(cards: [CardList.Card]) {
        cardListView.reload(cards: cards)
    }

    func remove(card: CardList.Card) {
        cardListView.remove(card: card)
    }

    func show(alert: CardList.Alert) {
        if let alertView = externalAlertsFactory?.presentAlertView(
            alert.title,
            message: alert.message,
            dismissCompletion: nil
        ) {
            present(alertView, animated: true)
        } else {
            let alertView = AcquiringAlertViewController.create()
            alertView.present(on: self, title: alert.title, icon: alert.icon)
        }
    }

    func showLoader() {
        cardListView.showLoader()
    }

    func hideLoader() {
        cardListView.hideLoader()
    }
}

// MARK: - CardListViewDelegate

extension CardListViewController: CardListViewDelegate {
    func cardListView(_ view: CardListView, didSelectCard item: CardList.Card) {
        presenter.view(didSelect: item)
    }

    func cardListView(_ view: CardListView, didTapDeleteOn card: CardList.Card) {
        let alert = UIAlertController.deleteConfirmation(
            withPAN: card.pan,
            onConfirm: { [presenter] in
                presenter.view(didTapDeleteOn: card)
            }
        )

        present(alert, animated: true)
    }

    func cardListViewDidTapPrimaryButton(_ view: CardListView) {
        presenter.viewDidTapPrimaryButton()
    }
}

// MARK: - UIAlertController + Delete Confirmation

private extension UIAlertController {
    static func deleteConfirmation(
        withPAN pan: String,
        onConfirm: @escaping () -> Void
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: L10n.CardList.Alert.Title.deleteCard,
            message: L10n.CardList.Alert.Message.deleteCard(pan),
            preferredStyle: .alert
        )

        let cancel = UIAlertAction(
            title: L10n.CardList.Alert.Action.cancel,
            style: .cancel
        )

        let delete = UIAlertAction(
            title: L10n.CardList.Alert.Action.delete,
            style: .destructive,
            handler: { _ in onConfirm() }
        )

        [cancel, delete].forEach(alert.addAction)
        return alert
    }
}
