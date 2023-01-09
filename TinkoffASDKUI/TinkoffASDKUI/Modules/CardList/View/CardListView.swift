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

enum CardListSection {
    case cards(data: [CardList.Card])
    case addCard(data: [(icon: ImageAsset, title: String)])
}

protocol CardListViewDelegate: AnyObject {
    func cardListView(_ view: CardListView, didTapDeleteOn card: CardList.Card)
    // collection delegate
    func didSelectCell(at: IndexPath)
}

final class CardListView: UIView {

    // MARK: Style

    struct Style {
        let listItemsAreSelectable: Bool
        let backgroundColor: UIColor
    }

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
        collectionView.register(cellClasses: PaymentCardRemovableView.Cell.self, IconTitleView.Cell.self, UICollectionViewCell.self)
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

    private var sections: [CardListSection] = []

    // MARK: Init

    init(style: Style, stubBuilder: IStubViewBuilder, delegate: CardListViewDelegate? = nil) {
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

    func reload(sections: [CardListSection]) {
        self.sections = sections
        collectionView.reloadData()
    }

    func deleteItems(at indexes: [IndexPath]) {
        collectionView.deleteItems(at: indexes)
    }

    func disableUserInteraction() {
        guard blockingView.superview == nil else { return }
        blockingView.alpha = 1
        addSubview(blockingView)
        blockingView.pinEdgesToSuperview()

        UIView.addPopingAnimation {
            self.collectionView.alpha = 0.5
        }
    }

    func enableUserInteraction() {
        blockingView.alpha = 0

        UIView.addPopingAnimation(animations: {
            self.collectionView.alpha = 1
        }, completion: { [weak self] _ in
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
        collectionView.isHidden = true
        let stubView = stubBuilder.buildFrom(coverMode: mode)
        stubView.center = center
        stubView.alpha = .zero
        addSubview(stubView)
        UIView.addPopingAnimation { stubView.alpha = 1 }
    }

    func hideStub() {
        collectionView.isHidden = false
        subviews.forEach { subview in
            if subview is StubView {
                UIView.addPopingAnimation(
                    animations: {
                        subview.alpha = .zero
                    },
                    completion: { _ in
                        subview.removeFromSuperview()
                    }
                )
            }
        }
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

        blockingView.backgroundColor = .clear
    }
}

// MARK: - UICollectionViewDataSource

extension CardListView: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        let section = sections[section]
        switch section {
        case let .cards(configs):
            return configs.count
        case let .addCard(configs):
            return configs.count
        }

        return .zero
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let section = sections[indexPath.section]

        switch section {
        case let .cards(data):
            let model = data[indexPath.item]
            let accesoryItem: PaymentCardRemovableView.AccessoryItem = model.isInEditingMode
                ? .removeButton(onRemove: { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.cardListView(self, didTapDeleteOn: model)
                })
                : .none

            let configuration = PaymentCardRemovableView.Cell.Configuration(
                content: .plain(text: model.assembledText, style: .bodyL()),
                card: model.cardModel,
                accessoryItem: accesoryItem,
                insets: PaymentCardRemovableView.contentInsets
            )

            let cell = collectionView
                .dequeue(PaymentCardRemovableView.Cell.self, for: indexPath)
            cell.shouldHighlight = false

            cell.customAutolayoutForContent = {
                $0.makeConstraints { view in
                    view.edgesEqualToSuperview() + [view.width(constant: self.frame.width)]
                }
            }
            cell.update(with: configuration)
            return cell

        case let .addCard(data):
            let model = data[indexPath.item]
            let cell = collectionView.dequeue(IconTitleView.Cell.self, for: indexPath)
            cell.customAutolayoutForContent = {
                $0.makeConstraints { view in
                    view.edgesEqualToSuperview() + [view.width(constant: self.frame.width)]
                }
            }
            let config = IconTitleView.Configuration.buildAddCardButton(
                icon: model.icon.image,
                text: model.title
            )

            cell.update(with: config)
            return cell
        }
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

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        delegate?.didSelectCell(at: indexPath)
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
