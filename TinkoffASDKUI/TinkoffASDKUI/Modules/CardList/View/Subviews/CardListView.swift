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

// MARK: - Screen Configuration

struct CardListScreenConfiguration {
    let listItemsAreSelectable: Bool
    let navigationTitle: String
    let addNewCardCellTitle: String
    let selectedCardId: String?
}

final class CardListView: UIView, StubViewPresentable {

    // MARK: Dependencies

    weak var delegate: CardListViewDelegate?
    private let viewConfiguration: CardListScreenConfiguration

    // MARK: UI

    var stubViewPinTo: UIView { self }

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cellClasses: PaymentCardRemovableView.Cell.self, IconTitleView.Cell.self, UICollectionViewCell.self)
        return collectionView
    }()

    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = .zero
        return layout
    }()

    private let blockingView = UIView()

    private lazy var shimmerView = buildShimmerView()

    // MARK: State

    private var sections: [CardListSection] = []

    // MARK: Init

    init(
        configuration: CardListScreenConfiguration,
        delegate: CardListViewDelegate? = nil
    ) {
        viewConfiguration = configuration
        self.delegate = delegate
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

    func setCollectionView(isHidden: Bool) {
        collectionView.isHidden = isHidden
    }

    // MARK: Initial Configuration

    private func setupView() {
        backgroundColor = ASDKColors.Background.elevation1.color
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
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let section = sections[indexPath.section]

        switch section {
        case let .cards(data):
            let model = data[indexPath.item]
            var accesoryItem: PaymentCardRemovableView.AccessoryItem = .none

            if model.isInEditingMode {
                accesoryItem = .removeButton(onRemove: { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.cardListView(self, didTapDeleteOn: model)
                })
            } else if model.hasCheckmarkInNormalMode {
                accesoryItem = .checkmark
            }

            let textStyle = UILabel.Style.bodyL().set(numberOfLines: 1)
            let configuration = PaymentCardRemovableView.Cell.ContentConfiguration(
                bankNameContent: .plain(text: model.bankNameText, style: textStyle),
                cardNumberContent: .plain(text: model.cardNumberText, style: textStyle),
                card: model.cardModel,
                accessoryItem: accesoryItem,
                insets: PaymentCardRemovableView.contentInsets
            )

            let cell = collectionView
                .dequeue(PaymentCardRemovableView.Cell.self, for: indexPath)

            cell.update(
                with: CollectionCell<PaymentCardRemovableView>.Configuration(
                    contentConfiguration: configuration,
                    shouldHighlight: viewConfiguration.listItemsAreSelectable
                )
            )

            return cell

        case let .addCard(data):
            let model = data[indexPath.item]
            let cell = collectionView.dequeue(IconTitleView.Cell.self, for: indexPath)

            let config = IconTitleView.Configuration.buildAddCardButton(
                icon: model.icon.image,
                text: model.title
            )

            cell.update(with: CollectionCell<IconTitleView>.Configuration(contentConfiguration: config))
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
        var shouldPropagateCall = true
        switch indexPath.section {
        case .zero:
            shouldPropagateCall = viewConfiguration.listItemsAreSelectable
        default: break
        }

        guard shouldPropagateCall else { return }
        delegate?.didSelectCell(at: indexPath)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: frame.width, height: CGFloat.itemHeight)
    }
}

// MARK: - Constants

private extension CGFloat {
    static let itemHeight: CGFloat = 56
    static let buttonBottomInset: CGFloat = 40
    static let buttonHorizontalInsets: CGFloat = 16
    static let contentAdditionalSpaceFromButton: CGFloat = 16
}
