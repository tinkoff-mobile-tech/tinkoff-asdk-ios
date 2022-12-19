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
    func disableViewUserInteraction()
    func enableViewUserInteraction()
    func showShimmer()
    func hideShimmer()
    func showStub(mode: StubMode)
    func hideStub()
    func addCard()
    func dismiss()
    func showDoneEditingButton()
    func showEditButton()
    func showNativeAlert(title: String?, message: String?, buttonTitle: String?)
    func dismissAlert()
    func showLoadingSnackbar(text: String?)
    func hideLoadingSnackbar()
}

final class CardListViewController: UIViewController {
    // MARK: Dependencies

    private let presenter: ICardListViewOutput
    private weak var externalAlertsFactory: AcquiringAlertViewProtocol?

    // MARK: Views

    private let cardListView: CardListView

    // MARK: State

    private var snackBarViewController: SnackbarViewController?

    // MARK: Init

    init(
        style: CardListView.Style,
        presenter: ICardListViewOutput,
        externalAlertsFactory: AcquiringAlertViewProtocol?,
        stubBuilder: IStubViewBuilder
    ) {
        self.presenter = presenter
        self.externalAlertsFactory = externalAlertsFactory
        cardListView = CardListView(style: style, stubBuilder: stubBuilder)
        super.init(nibName: nil, bundle: nil)
        cardListView.delegate = self
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
        title = Loc.Acquiring.CardList.screenTitle
        navigationItem.largeTitleDisplayMode = .never

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: Loc.TinkoffAcquiring.Button.close,
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )

        navigationItem.rightBarButtonItem = buildEditBarButton()
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

    func disableViewUserInteraction() {
        cardListView.disableUserInteraction()
    }

    func enableViewUserInteraction() {
        cardListView.enableUserInteraction()
    }

    func showShimmer() {
        cardListView.startShimmer(showing: true, completion: {})
    }

    func hideShimmer() {
        cardListView.startShimmer(
            showing: false,
            completion: { [weak presenter] in
                presenter?.viewDidHideShimmer()
            }
        )
    }

    func showStub(mode: StubMode) {
        cardListView.showStub(mode: mode)
    }

    func hideStub() {
        cardListView.hideStub()
    }

    func addCard() {
        cardListView.addCard()
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

    func showNativeAlert(
        title: String?,
        message: String?,
        buttonTitle: String?
    ) {
        let alert = UIAlertController.okAlert(
            title: title,
            message: message,
            buttonTitle: buttonTitle,
            onTap: { [weak presenter] in
                presenter?.viewNativeAlertDidTapButton()
            }
        )

        present(alert, animated: true)
    }

    func dismissAlert() {
        presentedViewController?.dismiss(animated: true)
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
        snackBarViewController = showSnack(config: config, completion: nil)
    }

    func hideLoadingSnackbar() {
        snackBarViewController?.hideSnackView(
            animated: true,
            completion: { [weak self] in
                self?.presenter.viewDidHideLoadingSnackbar()
                self?.snackBarViewController = nil
            }
        )
    }
}

// MARK: - CardListViewDelegate

extension CardListViewController: CardListViewDelegate {

    func didSelectCell(section: CardListSection, indexItem: Int) {
        switch section {
        case .cards:
            presenter.viewDidTapCard(cardIndex: indexItem)
        case .addCard:
            presenter.viewDidTapAddCardCell()
        }
    }

    func cardListView(_ view: CardListView, didTapDeleteOn card: CardList.Card) {
        presenter.view(didTapDeleteOn: card)
    }

    func cardListViewDidTapPrimaryButton(_ view: CardListView) {
        presenter.viewDidTapPrimaryButton()
    }

    func getNumberOfSections() -> Int {
        presenter.viewNumberOfSections()
    }

    func getNumberOfItems(forSection: Int) -> Int {
        assert(CardListSection(rawValue: forSection) != nil)
        guard let section = CardListSection(rawValue: forSection) else { return .zero }
        return presenter.viewNumberOfItems(forSection: section)
    }

    func getCellModel<Model>(section: CardListSection, itemIndex: Int) -> Model? {
        presenter.viewCellModel(section: section, itemIndex: itemIndex)
    }
}

// MARK: - UIAlertController + Delete Confirmation

private extension UIAlertController {

    static func okAlert(
        title: String?,
        message: String?,
        buttonTitle: String?,
        onTap: @escaping () -> Void
    ) -> UIAlertController {

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        let ok = UIAlertAction(
            title: buttonTitle,
            style: .default,
            handler: { _ in }
        )

        alert.addAction(ok)
        return alert
    }
}

extension CardListViewController: ISnackBarPresentable, ISnackBarViewProvider {

    var viewProvider: ISnackBarViewProvider? { self }
    func viewToAddSnackBarTo() -> UIView { view }
}
