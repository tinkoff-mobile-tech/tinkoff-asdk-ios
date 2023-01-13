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

import TinkoffASDKCore
import UIKit

protocol ICardListViewInput: AnyObject {
    func reload(sections: [CardListSection])
    func deleteItems(at: [IndexPath])
    func disableViewUserInteraction()
    func enableViewUserInteraction()
    func showShimmer()
    func hideShimmer(fetchCardsResult: Result<[PaymentCard], Error>)
    func showStub(mode: StubMode)
    func hideStub()
    func dismiss()
    func showDoneEditingButton()
    func showEditButton()
    func hideRightBarButton()
    func showNativeAlert(data: OkAlertData)
    func showLoadingSnackbar(text: String?)
    func hideLoadingSnackbar()
    func showAddedCardSnackbar(cardMaskedPan: String)
    func closeScreen()
}

final class CardListViewController: UIViewController {
    // MARK: Dependencies

    private let presenter: ICardListViewOutput

    private let style: CardListView.Style

    // MARK: Views

    private lazy var cardListView = CardListView(style: style)

    // MARK: State

    private var snackBarViewController: SnackbarViewController?

    private var sections: [CardListSection] = []

    // MARK: Init

    init(
        style: CardListView.Style,
        presenter: ICardListViewOutput
    ) {
        self.presenter = presenter
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life Cycle

    override func loadView() {
        view = cardListView
        cardListView.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        presenter.viewDidLoad()
    }

    // MARK: Initial Configuration

    private func setupNavigationItem() {
        title = Loc.Acquiring.CardList.screenTitle
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backButtonTitle = ""

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: Loc.TinkoffAcquiring.Button.close,
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
    }

    private func buildEditBarButton() -> UIBarButtonItem {
        UIBarButtonItem(
            title: Loc.Acquiring.CardList.buttonChange,
            style: .plain,
            target: self,
            action: #selector(editButtonTapped)
        )
    }

    private func buildDoneEditingBarButton() -> UIBarButtonItem {
        UIBarButtonItem(
            title: Loc.Acquiring.CardList.buttonDone,
            style: .plain,
            target: self,
            action: #selector(doneEditingButtonTapped)
        )
    }

    // MARK: Actions

    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func editButtonTapped() {
        presenter.viewDidTapEditButton()
    }

    @objc private func doneEditingButtonTapped() {
        presenter.viewDidTapDoneEditingButton()
    }
}

// MARK: - ICardListViewController

extension CardListViewController: ICardListViewInput {

    func reload(sections: [CardListSection]) {
        self.sections = sections
        cardListView.reload(sections: sections)
    }

    func deleteItems(at array: [IndexPath]) {
        cardListView.deleteItems(at: array)
    }

    func disableViewUserInteraction() {
        cardListView.disableUserInteraction()
    }

    func enableViewUserInteraction() {
        cardListView.enableUserInteraction()
    }

    func showShimmer() {
        cardListView.startShimmer(showing: true, completion: {})
    }

    func hideShimmer(fetchCardsResult: Result<[PaymentCard], Error>) {
        cardListView.startShimmer(
            showing: false,
            completion: { [weak presenter] in
                presenter?.viewDidHideShimmer(fetchCardsResult: fetchCardsResult)
            }
        )
    }

    func showStub(mode: StubMode) {
        cardListView.showStubView(mode: mode)
    }

    func hideStub() {
        cardListView.hideStubView()
    }

    func dismiss() {
        dismiss(animated: true)
    }

    func showDoneEditingButton() {
        navigationItem.rightBarButtonItem = buildDoneEditingBarButton()
    }

    func showEditButton() {
        navigationItem.rightBarButtonItem = buildEditBarButton()
    }

    func hideRightBarButton() {
        navigationItem.rightBarButtonItem = nil
    }

    func showNativeAlert(data: OkAlertData) {
        let alert = UIAlertController.okAlert(data: data)
        present(alert, animated: true)
    }

    func showLoadingSnackbar(text: String?) {
        let config = SnackbarView.Configuration(
            content: .loader(
                configuration: LoaderTitleView.Configuration(
                    title: UILabel.Configuration(
                        content: .plain(text: text, style: .bodyM())
                    )
                )
            ),
            style: .base
        )
        snackBarViewController = showSnack(animated: true, config: config, completion: nil)
    }

    func hideLoadingSnackbar() {
        snackBarViewController?.hideSnackView(
            animated: true,
            completion: { [weak self] _ in
                self?.presenter.viewDidHideLoadingSnackbar()
                self?.snackBarViewController = nil
            }
        )
    }

    func showAddedCardSnackbar(cardMaskedPan: String) {
        let config = SnackbarView.Configuration(
            content: .iconTitle(
                icon: Asset.Icons.addedCard.image,
                text: Loc.Acquiring.CardList.addSnackBar(cardMaskedPan)
            ),
            style: .base
        )

        presenter.viewDidShowAddedCardSnackbar()
        showSnackFor(
            seconds: 1,
            animated: false,
            config: config,
            didShowCompletion: nil,
            didHideCompletion: nil
        )
    }

    func closeScreen() {
        closeButtonTapped()
    }
}

// MARK: - CardListViewDelegate

extension CardListViewController: CardListViewDelegate {

    func didSelectCell(at indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .cards:
            presenter.viewDidTapCard(cardIndex: indexPath.item)
        case .addCard:
            presenter.viewDidTapAddCardCell()
        }
    }

    func cardListView(_ view: CardListView, didTapDeleteOn card: CardList.Card) {
        presenter.view(didTapDeleteOn: card)
    }
}

extension CardListViewController: ISnackBarPresentable, ISnackBarViewProvider {

    var viewProvider: ISnackBarViewProvider? { self }
    func viewToAddSnackBarTo() -> UIView { view }
}

extension CardListViewController {

    func getAddNewCardOutput() -> IAddNewCardOutput {
        presenter
    }
}
