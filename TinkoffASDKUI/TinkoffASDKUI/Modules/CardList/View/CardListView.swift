//
//
//  CardListView.swift
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

protocol CardListViewDelegate: AnyObject {
    func cardListView(_ view: CardListView, didSelectCard card: CardList.Card)
    func cardListView(_ view: CardListView, didTapDeleteOn card: CardList.Card)
    func cardListViewDidTapPrimaryButton(_ view: CardListView)
}

final class CardListView: UIView {

    // MARK: Style

    struct Style {
        let listItemsAreSelectable: Bool
        let primaryButtonStyle: TinkoffASDKUI.ButtonStyle?
        let backgroundColor: UIColor
    }

    // MARK: Private Types

    private typealias CardCell = CollectionCell<PaymentCardRemovableView>

    // MARK: Dependencies

    weak var delegate: CardListViewDelegate?
    private let style: Style

    // MARK: UI

    private lazy var overlayLoadingView = OverlayLoadingView(
        style: OverlayLoadingView.Style(overlayColor: style.backgroundColor)
    )

    private lazy var noCardsView: MessageView = {
        let view = MessageView(style: .noCards)
        view.backgroundColor = style.backgroundColor
        view.isHidden = true
        view.alpha = .zero
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cellClasses: CardCell.self)
        collectionView.backgroundColor = style.backgroundColor
        collectionView.allowsSelection = style.listItemsAreSelectable
        return collectionView
    }()

    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        return layout
    }()

    private lazy var primaryButton: ASDKButton = {
        let button = ASDKButton(
            style: .primary(
                title: L10n.CardList.Button.addNewCard,
                buttonStyle: style.primaryButtonStyle
            )
        )
        button.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: State

    private var cards: [CardList.Card] = []

    // MARK: Init

    init(style: Style, delegate: CardListViewDelegate? = nil) {
        self.style = style
        self.delegate = delegate
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Updating

    func reload(cards: [CardList.Card]) {
        self.cards = cards
        collectionView.reloadSections(IndexSet(integer: .zero))
        updateNoCardsViewVisibility()
    }

    func remove(card: CardList.Card) {
        guard let removingIndex = cards.firstIndex(where: { $0.id == card.id }) else {
            return
        }
        cards.remove(at: removingIndex)
        collectionView.deleteItems(at: [IndexPath(item: removingIndex, section: .zero)])
        updateNoCardsViewVisibility()
    }

    func showLoader() {
        overlayLoadingView.state = .shown
        primaryButton.isEnabled = false
    }

    func hideLoader() {
        overlayLoadingView.state = .hidden
        primaryButton.isEnabled = true
    }

    // MARK: Initial Configuration

    private func setupView() {
        backgroundColor = style.backgroundColor

        addSubview(collectionView)
        collectionView.pinEdgesToSuperview()

        addSubview(noCardsView)
        noCardsView.pinEdgesToSuperview()

        addSubview(overlayLoadingView)
        overlayLoadingView.pinEdgesToSuperview()

        addSubview(primaryButton)
        primaryButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            primaryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            primaryButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.buttonBottomInset),
            primaryButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .buttonHorizontalInsets),
            primaryButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.buttonHorizontalInsets)
        ])
    }

    // MARK: State Updating

    private func updateNoCardsViewVisibility() {
        let shouldShow = cards.isEmpty

        let animations = { [self] in
            noCardsView.alpha = shouldShow ? 1 : .zero
        }

        let completion = { [self] (completed: Bool) in
            guard completed else { return }
            noCardsView.isHidden = !shouldShow
        }

        noCardsView.isHidden = false
        UIView.animate(
            withDuration: .noCardsViewAnimationDuration,
            delay: .zero,
            options: .curveEaseInOut,
            animations: animations,
            completion: completion
        )
    }

    // MARK: Actions

    @objc private func primaryButtonTapped() {
        delegate?.cardListViewDidTapPrimaryButton(self)
    }
}

// MARK: - UICollectionViewDataSource

extension CardListView: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        cards.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let card = cards[indexPath.row]
        let cell = collectionView.dequeue(CardCell.self, for: indexPath)

        let configuration = CardCell.Configuration(
            pan: card.pan,
            validThru: card.validThru,
            icon: card.icon,
            removeHandler: { [weak self] in
                guard let self = self else { return }
                self.delegate?.cardListView(self, didTapDeleteOn: card)
            }
        )

        cell.update(with: configuration)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension CardListView: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let card = cards[indexPath.row]
        delegate?.cardListView(self, didSelectCard: card)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CardListView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: .itemHeight)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        .zero
    }
}

// MARK: - Constants

private extension CGFloat {
    static let itemHeight: CGFloat = 56
    static let buttonBottomInset: CGFloat = 40
    static let buttonHorizontalInsets: CGFloat = 16
}

private extension TimeInterval {
    static let noCardsViewAnimationDuration: TimeInterval = 0.2
}

// MARK: - MessageView + Style

private extension MessageView.Style {
    static var noCards: MessageView.Style {
        MessageView.Style(
            largeImage: Asset.Illustrations.illustrationsCommonLightCard.image,
            message: L10n.CardList.Status.noCards
        )
    }
}
