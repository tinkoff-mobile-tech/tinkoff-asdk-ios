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

protocol IAddNewCardOutput: AnyObject {
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
    func closeNativeAlert()
    func showAlreadySuchCardErrorNativeAlert()
    func showGenericErrorNativeAlert()
    func disableAddButton()
    func enableAddButton()
}

// MARK: - AddNewCardViewController

final class AddNewCardViewController: UIViewController {

    private weak var output: IAddNewCardOutput?
    private let presenter: IAddNewCardPresenter

    private let keyboardService = KeyboardService()

    // UI

    private lazy var collectionView: UICollectionView = prepareCollectionView()
    private let addButton = Button()
    private let blockingView = UIView()

    // Local State

    private var sections: [AddNewCardSection] = []

    init(
        output: IAddNewCardOutput,
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        presenter.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard addButton.frame.size == .zero else { return }
        setupAddButton()
    }
}

// MARK: - IAddNewCardView

extension AddNewCardViewController: IAddNewCardView {

    func reloadCollection(sections: [AddNewCardSection]) {
        self.sections = sections
        collectionView.reloadData()
    }

    func showLoadingState() {
        UIView.addPopingAnimation {
            self.blockingView.alpha = 0.5
        }

        view.endEditing(true)
        addButton.startLoading()
    }

    func hideLoadingState() {
        UIView.addPopingAnimation {
            self.blockingView.alpha = .zero
        }

        addButton.stopLoading()
    }

    func notifyAdded(card: PaymentCard) {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.3,
            execute: {
                self.output?.addNewCardDidAddCard(paymentCard: card)
            }
        )
    }

    func closeScreen() {
        navigationController?.popViewController(animated: true)
    }

    func showGenericErrorNativeAlert() {
        let alertViewController = UIAlertController.okAlert(
            title: Loc.CommonAlert.SomeProblem.title,
            message: Loc.CommonAlert.SomeProblem.description,
            buttonTitle: Loc.CommonAlert.button,
            onTap: { [weak presenter] in
                presenter?.viewDidTapOkGenericErrorAlert()
            }
        )

        present(alertViewController, animated: true)
    }

    func showAlreadySuchCardErrorNativeAlert() {
        let alertViewController = UIAlertController.okAlert(
            title: Loc.CommonAlert.AddCard.title,
            message: nil,
            buttonTitle: Loc.CommonAlert.button,
            onTap: { [weak presenter] in
                presenter?.viewDidTapHasSuchCardErrorAlert()
            }
        )

        present(alertViewController, animated: true)
    }

    func disableAddButton() {
        addButton.isEnabled = false
    }

    func enableAddButton() {
        addButton.isEnabled = true
    }

    func closeNativeAlert() {
        presentedViewController?.dismiss(animated: true)
    }
}

extension AddNewCardViewController {

    private func setupViews() {
        keyboardService.onHeightDidChangeBlock = { [weak self] height in
            self?.collectionView.contentInset.bottom = height + UIWindow.globalSafeAreaInsets.bottom

            UIView.animate(
                withDuration: KeyboardService.animationDuration,
                delay: .zero
            ) {
                self?.addButton.frame.origin.y = self?.calculateAddButtonYPoint(keyboardHeight: height) ?? .zero
            }
        }

        view.backgroundColor = ASDKColors.Background.base.color
        setupNavigationItem()

        view.addSubview(collectionView)
        view.addSubview(blockingView)
        view.addSubview(addButton)

        collectionView.pinEdgesToSuperview()
        blockingView.pinEdgesToSuperview()
        blockingView.backgroundColor = view.backgroundColor
        blockingView.alpha = .zero
    }

    private func setupAddButton() {
        let yOrigin = calculateAddButtonYPoint(keyboardHeight: .zero)
        addButton.frame = CGRect(
            x: Constants.AddButton.horizontalInset,
            y: yOrigin,
            width: view.frame.width - (Constants.AddButton.horizontalInset * 2),
            height: Button.defaultHeight
        )

        addButton.configure(
            Constants.AddButton.getConfiguration { [weak presenter] in
                presenter?.viewAddCardTapped()
            }
        )
    }

    private func calculateAddButtonYPoint(keyboardHeight: CGFloat) -> CGFloat {
        if keyboardHeight > .zero {
            return view.frame.maxY - (Button.defaultHeight + Constants.AddButton.bottomInset + keyboardHeight)
        } else {
            return view.frame.maxY - (Button.defaultHeight + Constants.AddButton.bottomInsetWithSafeArea + keyboardHeight)
        }
    }

    private func prepareCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset.top = Constants.CollectionView.topInset
        collectionView.contentInset.bottom = UIWindow.globalSafeAreaInsets.bottom
        collectionView.register(cellClasses: UICollectionViewCell.self, CardFieldView.Cell.self)
        return collectionView
    }

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

extension AddNewCardViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        var numberOfItems = Int.zero

        sections.forEach { section in
            switch section {
            case let .cardField(configs):
                numberOfItems = configs.count
            }
        }

        return numberOfItems
    }
}

extension AddNewCardViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard sections.indices.contains(indexPath.section)
        else { return UICollectionViewCell() }

        switch sections[indexPath.section] {
        case let .cardField(configs):
            let config = configs[indexPath.item]
            return prepareCardFieldCell(indexPath: indexPath, config: config)
        }
    }

    private func prepareCardFieldCell(indexPath: IndexPath, config: CardFieldView.Configuration) -> UICollectionViewCell {
        let cell = collectionView.dequeue(CardFieldView.Cell.self, for: indexPath)
        cell.shouldHighlight = false
        cell.customAutolayoutForContent = { cardFielView in
            let insets = Constants.CollectionView.horizontalInsets
            let width = self.collectionView.frame.width - insets.horizontal
            let cardFieldHeight = cardFielView.systemLayoutSizeFitting(.zero).height
            let cardFieldSize = CGSize(width: width, height: cardFieldHeight)
            cardFielView.frame = CGRect(origin: .zero, size: cardFieldSize)

            cardFielView.makeConstraints { view in
                cardFielView.edgesEqualToSuperview(insets: insets) + [
                    view.width(constant: self.collectionView.frame.width - insets.horizontal),
                ]
            }
        }

        cell.update(with: config)
        presenter.viewDidReceiveCardFieldView(cardFieldView: cell.content)
        return cell
    }
}

extension AddNewCardViewController {

    struct Constants {
        struct CollectionView {
            static var horizontalInsets: UIEdgeInsets { UIEdgeInsets(horizontal: 16) }
            static var topInset: CGFloat { 20 }
        }

        struct AddButton {
            static var horizontalInset: CGFloat { 16 }
            static var bottomInset: CGFloat { 24 }

            static var bottomInsetWithSafeArea: CGFloat {
                UIWindow.globalSafeAreaInsets.bottom + Self.bottomInset
            }

            static func getConfiguration(action: @escaping () -> Void) -> Button.Configuration {

                return Button.Configuration(
                    data: Button.Data(
                        text: .basic(
                            normal: Loc.Acquiring.AddNewCard.addButton,
                            highlighted: nil,
                            disabled: nil
                        ),
                        onTapAction: action
                    ),
                    style: .primary
                )
            }
        }
    }
}
