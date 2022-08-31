//
//  CardListController.swift
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

protocol CardListViewInConnection {
    /// отрисовка карточек для сохраненных карт и новых реквизитов
    var contentCollectionView: UICollectionView! { get }
}

enum CardRequisitesState {
    /// новая карты, реквизиты: номер карты дата и cvc код
    case requisites(number: String?, expDate: String?, cvc: String?)
    /// ранее сохраненная карта и cvc код, для случаев когда его нужно ввести для оплаты
    case savedCard(card: PaymentCard, cvc: String?)
}

enum PaymentType {
    case standard
    case recurrent
}

protocol CardListViewOutConnection: InputViewStatus {
    var didSelectSBPItem: (() -> Void)? { get set }
    var didSelectShowCardList: (() -> Void)? { get set }

    func requisites() -> CardRequisitesState
    func waitCVCInput(forCardWith parentPaymentId: Int64, fieldActivated: @escaping (() -> Void))
    func updateView()
    func setPaymentType(_ paymentType: PaymentType)
    func presentCardList(
        dataSource: AcquiringCardListDataSourceDelegate?,
        in view: CardListViewInConnection,
        becomeFirstResponderListener: BecomeFirstResponderListener?,
        scanner: ICardRequisitesScanner?
    )
    
    func selectCard(withId cardId: String)
    func selectRequisitesInput()
}

class CardListController: NSObject {
    // MARK: Internal Types

    private enum ListItemType {
        case card(id: String)
        case requisites

        var isRequisites: Bool {
            guard case .requisites = self else {
                return false
            }
            return true
        }

        var cardId: String? {
            guard case let .card(cardId) = self else {
                return nil
            }

            return cardId
        }
    }

    private struct CellInfo {
        var type: ListItemType
        var index: Int
    }

    // MARK: CardListViewOutConnection Event Handlers

    var didSelectSBPItem: (() -> Void)?
    var didSelectShowCardList: (() -> Void)?

    // MARK: State

    private var cellIndex: [CellInfo] = []
    private var paymentType: PaymentType = .standard
    private var waitingInputCVCForParentPaymentId: Int64?
    private var waitingInputIndexPath: IndexPath?
    private var lastActiveCardIndexPath: IndexPath?

    // MARK: Services

    private lazy var inputCardRequisitesController: InputCardRequisitesDataSource = InputCardRequisitesController()
    private lazy var inputCardCVCRequisitesPresenter: InputCardCVCRequisitesViewOutConnection = InputCardCVCRequisitesPresenter()
    private let paymentSystemImageResolver: IPaymentSystemImageResolver = PaymentSystemImageResolver()

    // MARK: Weak objects

    private weak var cardListCollectionView: UICollectionView?
    private weak var dataSource: AcquiringCardListDataSourceDelegate?
    private weak var scanner: ICardRequisitesScanner?
    private weak var becomeFirstResponderListener: BecomeFirstResponderListener?

    // MARK: Helpers

    private func setupCardListCollectionView(_ collectionView: UICollectionView) {
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: .defaultCellIdentifier
        )
        collectionView.register(
            UINib(nibName: "PaymentCardCollectionViewCell", bundle: .uiResources),
            forCellWithReuseIdentifier: "PaymentCardCollectionViewCell"
        )
        collectionView.register(
            UINib(nibName: "CardListLoadingCollectionViewCell", bundle: .uiResources),
            forCellWithReuseIdentifier: "CardListLoadingCollectionViewCell"
        )
        collectionView.register(
            UINib(nibName: "CardListStatusCollectionViewCell", bundle: .uiResources),
            forCellWithReuseIdentifier: "CardListStatusCollectionViewCell"
        )
        collectionView.register(
            UINib(nibName: "PaymentCardInputRequisitesCollectionViewCell", bundle: .uiResources),
            forCellWithReuseIdentifier: "PaymentCardInputRequisitesCollectionViewCell"
        )

        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    private func getCardsForCurrentPaymentType() -> [PaymentCard] {
        guard let dataSource = dataSource else { return [] }

        switch paymentType {
        case .standard:
            return dataSource.getAllCards()
        case .recurrent:
            return dataSource.getAllCards().filter { $0.parentPaymentId != nil }
        }
    }

    private func scrollViewCurrentPage(_ scrollView: UIScrollView?) -> Int {
        if let scv = scrollView, cardListCollectionView == scv {
            let cellWidth = scv.bounds.size.width
            let currentPage = Int(scv.contentOffset.x / cellWidth)

            return currentPage
        }

        return 0
    }

    private func setupCollectionDataSource() {
        cellIndex = []
        switch dataSource?.getCardListFetchStatus() {
        case .object:
            let cards = getCardsForCurrentPaymentType()

            cards.enumerated().forEach { index, card in
                cellIndex.append(CellInfo(type: .card(id: card.cardId), index: index))

                if let parentPaymentId = waitingInputCVCForParentPaymentId,
                   cards[index].parentPaymentId == parentPaymentId {
                    waitingInputIndexPath = IndexPath(item: index, section: 0)
                }
            }
        default:
            break
        }
        cellIndex.append(CellInfo(type: .requisites, index: 0))
    }
}

// MARK: UICollectionViewDelegate

extension CardListController: UICollectionViewDelegate {
    func numberOfSections(in _: UICollectionView) -> Int {
        setupCollectionDataSource()
        return 1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return cellIndex.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard collectionView === cardListCollectionView else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: .defaultCellIdentifier, for: indexPath)
        }

        let cellInfo = cellIndex[indexPath.row]

        switch cellInfo.type {
        case .card:
            switch dataSource?.getCardListFetchStatus() {
            case .loading:
                if let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "CardListLoadingCollectionViewCell",
                    for: indexPath
                ) as? LoadingCollectionViewCell {
                    cell.activityIndicator.startAnimating()
                    return cell
                }
            case .object:
                if let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "PaymentCardCollectionViewCell",
                    for: indexPath
                ) as? PaymentCardCollectionViewCell {
                    let cards = getCardsForCurrentPaymentType()

                    let card = cards[cellInfo.index]
                    cell.labelCardName.text = card.pan
                    cell.labelCardExpData.text = card.expDateFormat()

                    let paymentSystemImage = paymentSystemImageResolver.resolve(by: card.pan)
                    cell.imageViewLogo?.image = paymentSystemImage
                    cell.imageViewLogo?.isHidden = paymentSystemImage == nil

                    if let parentPaymentId = waitingInputCVCForParentPaymentId, parentPaymentId == card.parentPaymentId {
                        cell.textFieldCardCVC.isHidden = false
                        inputCardCVCRequisitesPresenter.present(responderListener: becomeFirstResponderListener, inputView: cell)
                    } else {
                        let isCvcAndDateHidden: Bool
                        switch paymentType {
                        case .recurrent:
                            isCvcAndDateHidden = true
                            inputCardCVCRequisitesPresenter.present(responderListener: nil, inputView: nil)
                        case .standard:
                            isCvcAndDateHidden = false
                            inputCardCVCRequisitesPresenter.present(responderListener: becomeFirstResponderListener, inputView: cell)
                        }
                        cell.textFieldCardCVC.isHidden = isCvcAndDateHidden
                        cell.labelCardExpData.isHidden = isCvcAndDateHidden
                    }

                    return cell
                }

            case .empty:
                if let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "CardListStatusCollectionViewCell",
                    for: indexPath
                ) as? CardListStatusCollectionViewCell {
                    cell.buttonAction.isHidden = true
                    cell.buttonAction.setTitle(nil, for: .normal)
                    return cell
                }

            case .error:
                if let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "PaymentCardInputRequisitesCollectionViewCell",
                    for: indexPath
                ) as? PaymentCardInputRequisitesCollectionViewCell {
                    inputCardRequisitesController.setup(
                        responderListener: becomeFirstResponderListener,
                        inputView: cell,
                        inputAccessoryView: nil,
                        scaner: nil
                    )

                    return cell
                }
            default:
                break
            }
        case .requisites:
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PaymentCardInputRequisitesCollectionViewCell",
                for: indexPath
            ) as? PaymentCardInputRequisitesCollectionViewCell {
                inputCardRequisitesController.setup(
                    responderListener: becomeFirstResponderListener,
                    inputView: cell,
                    inputAccessoryView: nil,
                    scaner: scanner
                )

                return cell
            }
        }
        return collectionView.dequeueReusableCell(
            withReuseIdentifier: .defaultCellIdentifier,
            for: indexPath
        )
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension CardListController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout _: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        collectionView.bounds.size
    }
}

// MARK: UICollectionViewDataSource

extension CardListController: UICollectionViewDataSource {}

// MARK: - UIScrollViewDelegate

extension CardListController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.firstResponder?.resignFirstResponder()

        let indexPath = IndexPath(item: scrollViewCurrentPage(scrollView), section: 0)
        lastActiveCardIndexPath = indexPath

        if let cell = cardListCollectionView?.cellForItem(at: indexPath) as? PaymentCardCollectionViewCell {
            if cell.textFieldCardCVC.isHidden == false {
                inputCardCVCRequisitesPresenter.present(responderListener: becomeFirstResponderListener, inputView: cell)
            }
        }
    }
}

// MARK: - CardListViewOutConnection

extension CardListController: CardListViewOutConnection {
    func requisites() -> CardRequisitesState {
        let selectedCardCellIndex = scrollViewCurrentPage(cardListCollectionView)

        switch cellIndex[selectedCardCellIndex].type {
        case .card:
            if let card = dataSource?.getCardListCard(at: selectedCardCellIndex) {
                let cvc = inputCardCVCRequisitesPresenter.cardCVC()
                return CardRequisitesState.savedCard(card: card, cvc: cvc)
            }

        case .requisites:
            let requisites = inputCardRequisitesController.requisies()
            return CardRequisitesState.requisites(number: requisites.number, expDate: requisites.expDate, cvc: requisites.cvc)
        }

        let requisites = inputCardRequisitesController.requisies()
        return CardRequisitesState.requisites(number: requisites.number, expDate: requisites.expDate, cvc: requisites.cvc)
    }

    func presentCardList(
        dataSource: AcquiringCardListDataSourceDelegate?,
        in view: CardListViewInConnection,
        becomeFirstResponderListener: BecomeFirstResponderListener?,
        scanner: ICardRequisitesScanner?
    ) {
        self.dataSource = dataSource
        self.becomeFirstResponderListener = becomeFirstResponderListener
        self.scanner = scanner

        setupCardListCollectionView(view.contentCollectionView)
        cardListCollectionView = view.contentCollectionView
    }

    func waitCVCInput(forCardWith parentPaymentId: Int64, fieldActivated: @escaping (() -> Void)) {
        waitingInputCVCForParentPaymentId = parentPaymentId
        cardListCollectionView?.isScrollEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.updateView()
            if let indexPath = self?.waitingInputIndexPath {
                self?.cardListCollectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if let cell = self?.cardListCollectionView?.cellForItem(at: indexPath) as? PaymentCardCollectionViewCell {
                        cell.textFieldCardCVC.isHidden = false
                        cell.textFieldCardCVC.becomeFirstResponder()
                    }
                }

                fieldActivated()
            }
        }
    }
    
    func setPaymentType(_ paymentType: PaymentType) {
        self.paymentType = paymentType
    }

    func updateView() {
        cardListCollectionView?.reloadData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            if let indexPath = self?.lastActiveCardIndexPath,
                indexPath.row != self?.scrollViewCurrentPage(self?.cardListCollectionView) {
                self?.cardListCollectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }

    func setStatus(_ value: InputFieldTableViewCellStatus, statusText: String?) {
        let indexPath = IndexPath(row: scrollViewCurrentPage(cardListCollectionView), section: 0)
        if let cell = cardListCollectionView?.cellForItem(at: indexPath) as? InputViewStatus {
            cell.setStatus(value, statusText: statusText)
        }
    }

    func selectCard(withId cardId: String) {
        guard let item = cellIndex
            .enumerated()
            .first(where: { $0.element.type.cardId == cardId })
            .map(\.offset) else {
            return
        }

        cardListCollectionView?.scrollToItem(
            at: IndexPath(item: item, section: .zero),
            at: .centeredHorizontally,
            animated: false
        )
    }

    func selectRequisitesInput() {
        guard let item = cellIndex
            .enumerated()
            .first(where: \.element.type.isRequisites)
            .map(\.offset) else {
            return
        }

        cardListCollectionView?.scrollToItem(
            at: IndexPath(item: item, section: .zero),
            at: .centeredHorizontally,
            animated: false
        )
    }
}

// MARK: - Constants

private extension String {
    static let defaultCellIdentifier = "defaultCell"
}
