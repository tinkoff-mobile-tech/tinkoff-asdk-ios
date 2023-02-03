//
//  AddNewCardView.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 27.12.2022.
//

import UIKit

protocol AddNewCardViewDelegate: AnyObject {
    func cardFieldViewAddCardTapped()

    func cardFieldViewPresenter() -> ICardFieldViewOutput
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

    private lazy var cardFieldView = CardFieldView()

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
        blockingView.alpha = 1
        UIView.addPopingAnimation {
            self.collectionView.alpha = 0.5
        }

        endEditing(true)
        addButton.startLoading()
    }

    func hideLoadingState() {
        blockingView.alpha = 0

        UIView.addPopingAnimation {
            self.collectionView.alpha = 1
        }

        addButton.stopLoading()
    }

    func disableAddButton() {
        addButton.isEnabled = false
    }

    func enableAddButton() {
        addButton.isEnabled = true
    }

    func activate() {
        cardFieldView.activate(textFieldType: .cardNumber)
    }
}

// MARK: - Private

extension AddNewCardView {

    private func setupViews() {
        keyboardService.onHeightDidChangeBlock = { [weak self] height, animationDuration in
            UIView.animate(
                withDuration: animationDuration,
                delay: .zero
            ) {
                self?.collectionView.contentInset.bottom = height + UIWindow.globalSafeAreaInsets.bottom
                self?.addButtonBottomConstraint.constant = self?.calculateAddButtonBottomInset(keyboardHeight: height) ?? .zero
                self?.layoutIfNeeded()
            }
        }

        backgroundColor = ASDKColors.Background.elevation1.color

        addSubview(collectionView)
        addSubview(blockingView)
        addSubview(addButton)

        setupAddButton()
        collectionView.pinEdgesToSuperview()
        blockingView.pinEdgesToSuperview()
        blockingView.backgroundColor = .clear
        blockingView.alpha = .zero
    }

    private func setupAddButton() {
        addButton.makeConstraints { view in
            [
                view.height(constant: Button.defaultHeight),
                addButtonBottomConstraint,
            ] + view.makeLeftAndRightEqualToSuperView(inset: Constants.AddButton.horizontalInset)
        }

        addButton.isEnabled = false
        addButton.configure(
            Constants.AddButton.getConfiguration { [weak self] in
                self?.delegate?.cardFieldViewAddCardTapped()
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
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset.top = Constants.CollectionView.topInset
        collectionView.contentInset.bottom = UIWindow.globalSafeAreaInsets.bottom
        collectionView.register(cellClasses: UICollectionViewCell.self, ContainerCollectionCell.self)
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

        switch sections[section] {
        case .cardField:
            numberOfItems = 1
        }

        return numberOfItems
    }
}

extension AddNewCardView: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        switch sections[indexPath.section] {
        case .cardField:
            return prepareCardFieldCell(indexPath: indexPath)
        }
    }

    private func prepareCardFieldCell(indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(ContainerCollectionCell.self, for: indexPath)
        cardFieldView.presenter = delegate?.cardFieldViewPresenter()
        cell.update(with: ContainerCollectionCell.Configuration(content: cardFieldView, shouldHighlight: false))
        return cell
    }
}

extension AddNewCardView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let cardFieldHeight = cardFieldView.systemLayoutSizeFitting(.zero).height
        let width = collectionView.frame.width - Constants.CollectionView.horizontalInsets.horizontal
        return CGSize(width: width, height: cardFieldHeight)
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
