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

enum CardListSection: Int, CaseIterable {
    case cards
    case addCard
}

protocol CardListViewDelegate: AnyObject {
    func cardListView(_ view: CardListView, didTapDeleteOn card: CardList.Card)
    func cardListViewDidTapPrimaryButton(_ view: CardListView)

    // collection data source
    func getNumberOfSections() -> Int
    func getNumberOfItems(forSection: Int) -> Int
    func getCellModel<Model>(section: CardListSection, itemIndex: Int) -> Model?

    // collection delegate
    func didSelectCell(section: CardListSection, indexItem: Int)
}

final class CardListView: UIView {

    // MARK: Style

    struct Style {
        let listItemsAreSelectable: Bool
        let backgroundColor: UIColor
    }

    // MARK: Private Types

    private typealias CardCell = CollectionCell<PaymentCardRemovableView>

    // MARK: Dependencies

    weak var delegate: CardListViewDelegate?
    private let style: Style
    private let stubBuilder: IStubViewBuilder

    // MARK: UI

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cellClasses: CardCell.self, IconTitleView.Cell.self, UICollectionViewCell.self)
        collectionView.backgroundColor = style.backgroundColor
        collectionView.allowsSelection = style.listItemsAreSelectable
        return collectionView
    }()

    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return layout
    }()

    private let blockingView = UIView()

    private lazy var shimmerView = buildShimmerView()

    // MARK: State

    private var cards: [CardList.Card] = []
    private var addCardButtonModel: Any?

    // MARK: Init

    init(style: Style, delegate: CardListViewDelegate? = nil, stubBuilder: IStubViewBuilder) {
        self.style = style
        self.delegate = delegate
        self.stubBuilder = stubBuilder
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
        collectionView.reloadData()
    }

    func remove(card: CardList.Card) {
        guard let removingIndex = cards.firstIndex(where: { $0.id == card.id }) else {
            return
        }
        cards.remove(at: removingIndex)
        collectionView.deleteItems(at: [IndexPath(item: removingIndex, section: .zero)])
    }

    func disableUserInteraction() {
        guard blockingView.superview == nil else { return }
        blockingView.alpha = 0
        addSubview(blockingView)
        blockingView.pinEdgesToSuperview()
        UIView.addPopingAnimation {
            self.blockingView.alpha = 0.5
        }
    }

    func enableUserInteraction() {
        UIView.addPopingAnimation(animations: {
            self.blockingView.alpha = 0
        }, completion: { [weak self] in
            self?.blockingView.removeFromSuperview()
        })
    }

    func startShimmer(showing: Bool, completion: (() -> Void)?) {
        // prevents running unnecessary  animations
        if shimmerView.alpha == (showing ? 1 : 0) {
            completion?()
            return
        }

        UIView.animate(
            withDuration: 0.3,
            delay: .zero,
            animations: { self.shimmerView.alpha = showing ? 1 : 0 },
            completion: { _ in completion?() }
        )
    }

    func showStub(mode: StubMode) {
        let stubView = stubBuilder.buildFrom(coverMode: mode)
        stubView.center = center
        stubView.alpha = .zero
        addSubview(stubView)
        UIView.addPopingAnimation { stubView.alpha = 1 }
    }

    func hideStub() {
        subviews.forEach { subview in
            if subview is StubView {
                UIView.addPopingAnimation(
                    animations: {
                        subview.alpha = .zero
                    },
                    completion: {
                        subview.removeFromSuperview()
                    }
                )
            }
        }
    }

    func addCard() {
        primaryButtonTapped()
    }

    // MARK: Initial Configuration

    private func setupView() {
        backgroundColor = style.backgroundColor
        addSubview(collectionView)
        collectionView.makeConstraints { view in
            [
                view.topAnchor.constraint(equalTo: view.forcedSuperview.safeAreaLayoutGuide.topAnchor),
                view.bottomAnchor.constraint(equalTo: view.forcedSuperview.bottomAnchor),
            ] + view.makeLeftAndRightEqualToSuperView(inset: .zero)
        }

        collectionView.contentInset.top = 16
        collectionView.contentInset.bottom = UIWindow.findKeyWindow()?.safeAreaInsets.bottom ?? .zero

        shimmerView.alpha = .zero
        addSubview(shimmerView)
        shimmerView.makeConstraints { view in
            [
                view.topAnchor.constraint(equalTo: collectionView.topAnchor),
                view.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),
            ]
                + view.makeLeftAndRightEqualToSuperView(inset: .zero)
        }

        blockingView.backgroundColor = style.backgroundColor
    }

    // MARK: Actions

    @objc private func primaryButtonTapped() {
        delegate?.cardListViewDidTapPrimaryButton(self)
    }
}

// MARK: - UICollectionViewDataSource

extension CardListView: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return delegate?.getNumberOfSections() ?? .zero
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return delegate?.getNumberOfItems(forSection: section) ?? .zero
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        assert(CardListSection.allCases.map(\.rawValue).contains(indexPath.section))
        let defaultCell = collectionView.dequeue(UICollectionViewCell.self, for: indexPath)

        guard let delegate = delegate
        else { return defaultCell }

        guard let section = CardListSection(rawValue: indexPath.section)
        else { return defaultCell }

        let itemIndex = indexPath.row

        switch section {
        case .cards:
            let cardModel: CardList.Card? = delegate.getCellModel(section: section, itemIndex: itemIndex)
            return prepareCardCell(cardModel: cardModel!, indexPath: indexPath)
        case .addCard:
            let addCardModel: IconTitleView.Configuration? = delegate.getCellModel(section: section, itemIndex: itemIndex)
            let cell = collectionView.dequeue(IconTitleView.Cell.self, for: indexPath)
            cell.customAutolayoutForContent = {
                $0.makeConstraints { view in
                    view.edgesEqualToSuperview() + [view.width(constant: self.frame.width)]
                }
            }
            cell.update(with: addCardModel!)
            return cell
        }
    }

    private func prepareCardCell(cardModel: CardList.Card, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(CardCell.self, for: indexPath)

        let accesoryItem: PaymentCardRemovableView.AccessoryItem = cardModel.isInEditingMode
            ? .removeButton(onRemove: { [weak self] in
                guard let self = self else { return }
                self.delegate?.cardListView(self, didTapDeleteOn: cardModel)
            })
            : .none

        let configuration = CardCell.Configuration(
            content: .plain(text: cardModel.assembledText, style: .bodyL()),
            card: cardModel.cardModel,
            accessoryItem: accesoryItem,
            insets: PaymentCardRemovableView.Constants.contentInsets
        )

        cell.customAutolayoutForContent = {
            $0.makeConstraints { view in
                view.edgesEqualToSuperview() + [view.width(constant: self.frame.width)]
            }
        }
        cell.update(with: configuration)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CardListView: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        .zero
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        .zero
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        .zero
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let section = CardListSection(rawValue: indexPath.section)
        else { return false }
        switch section {
        case .cards:
            self.collectionView(collectionView, didSelectItemAt: indexPath)
            return false
        case .addCard:
            return true
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let section = CardListSection(rawValue: indexPath.section) else { return }
        delegate?.didSelectCell(section: section, indexItem: indexPath.row)
    }
}

// MARK: - Constants

private extension CGFloat {
    static let itemHeight: CGFloat = 56
    static let buttonBottomInset: CGFloat = 40
    static let buttonHorizontalInsets: CGFloat = 16
    static let contentAdditionalSpaceFromButton: CGFloat = 16
}

// MARK: - MessageView + Style

private extension MessageView.Style {
    static var noCards: MessageView.Style {
        MessageView.Style(
            largeImage: Asset.Illustrations.illustrationsCommonLightCard.image,
            message: Loc.CardList.Status.noCards
        )
    }
}
