//
//  AddNewCardView.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 27.12.2022.
//

import UIKit

protocol AddNewCardViewDelegate: AnyObject {
    func viewAddCardTapped()
    func viewDidReceiveCardFieldView(cardFieldView: ICardFieldView)
}

final class AddNewCardView: UIView {

    weak var delegate: AddNewCardViewDelegate?

    // UI

    private lazy var collectionView: UICollectionView = prepareCollectionView()
    private let addButton = Button()
    private let blockingView = UIView()

    // Local State

    private var sections: [AddNewCardSection] = []

    private lazy var addButtonBottomConstraint: NSLayoutConstraint = addButton
        .bottomAnchor
        .constraint(
            equalTo: addButton.forcedSuperview.bottomAnchor,
            constant: calculateAddButtonBottomInset(keyboardHeight: .zero)
        )

    // Dependencies

    private let keyboardService = KeyboardService()

    // MARK: - Init

    init(delegate: AddNewCardViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}

// MARK: - Public

extension AddNewCardView {

    func reloadCollection(sections: [AddNewCardSection]) {
        self.sections = sections
        collectionView.reloadData()
    }

    func showLoadingState() {
        UIView.addPopingAnimation {
            self.blockingView.alpha = 0.5
        }

        endEditing(true)
        addButton.startLoading()
    }

    func hideLoadingState() {
        UIView.addPopingAnimation {
            self.blockingView.alpha = .zero
        }

        addButton.stopLoading()
    }

    func disableAddButton() {
        addButton.isEnabled = false
    }

    func enableAddButton() {
        addButton.isEnabled = true
    }
}

// MARK: - Private

extension AddNewCardView {

    private func setupViews() {
        keyboardService.onHeightDidChangeBlock = { [weak self] height in
            self?.collectionView.contentInset.bottom = height + UIWindow.globalSafeAreaInsets.bottom
            self?.addButtonBottomConstraint.constant = self?.calculateAddButtonBottomInset(keyboardHeight: height) ?? .zero

            UIView.animate(
                withDuration: KeyboardService.animationDuration,
                delay: .zero
            ) {
                self?.layoutIfNeeded()
            }
        }

        backgroundColor = ASDKColors.Background.base.color

        addSubview(collectionView)
        addSubview(blockingView)
        addSubview(addButton)

        setupAddButton()
        collectionView.pinEdgesToSuperview()
        blockingView.pinEdgesToSuperview()
        blockingView.backgroundColor = backgroundColor
        blockingView.alpha = .zero
    }

    private func setupAddButton() {
        addButton.makeConstraints { view in
            [
                view.height(constant: Button.defaultHeight),
                addButtonBottomConstraint,
            ] + view.makeLeftAndRightEqualToSuperView(inset: Constants.AddButton.horizontalInset)
        }

        addButton.configure(
            Constants.AddButton.getConfiguration { [weak delegate] in
                delegate?.viewAddCardTapped()
            }
        )
    }

    private func calculateAddButtonBottomInset(keyboardHeight: CGFloat) -> CGFloat {
        var inset = keyboardHeight

        if keyboardHeight > .zero {
            inset += Constants.AddButton.bottomInset
        } else {
            inset += Constants.AddButton.bottomInsetWithSafeArea
        }

        return -inset
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
}

// MARK: - Collection Data Source & Delegate

extension AddNewCardView: UICollectionViewDataSource {
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

extension AddNewCardView: UICollectionViewDelegate {

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
        delegate?.viewDidReceiveCardFieldView(cardFieldView: cell.content)
        return cell
    }
}

// MARK: - Constants

extension AddNewCardView {

    struct Constants {
        struct CollectionView {
            static var horizontalInsets: UIEdgeInsets { UIEdgeInsets(horizontal: 16) }
            static var topInset: CGFloat { 20 }
        }

        struct AddButton {}
    }
}

extension AddNewCardView.Constants.AddButton {

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
