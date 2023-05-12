//
//  CardListPresenterMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 24.03.2023
//

import Foundation
import TinkoffASDKCore
@testable import TinkoffASDKUI

final class CardListPresenterMock: ICardListViewOutput {

    // MARK: - viewDidLoad

    var viewDidLoadCallsCount = 0

    func viewDidLoad() {
        viewDidLoadCallsCount += 1
    }

    // MARK: - view

    var viewCallsCount = 0
    var viewReceivedArguments: CardList.Card?
    var viewReceivedInvocations: [CardList.Card] = []

    func view(didTapDeleteOn card: CardList.Card) {
        viewCallsCount += 1
        let arguments = card
        viewReceivedArguments = arguments
        viewReceivedInvocations.append(arguments)
    }

    // MARK: - viewDidTapEditButton

    var viewDidTapEditButtonCallsCount = 0

    func viewDidTapEditButton() {
        viewDidTapEditButtonCallsCount += 1
    }

    // MARK: - viewDidTapDoneEditingButton

    var viewDidTapDoneEditingButtonCallsCount = 0

    func viewDidTapDoneEditingButton() {
        viewDidTapDoneEditingButtonCallsCount += 1
    }

    // MARK: - viewDidHideRemovingCardSnackBar

    var viewDidHideRemovingCardSnackBarCallsCount = 0

    func viewDidHideRemovingCardSnackBar() {
        viewDidHideRemovingCardSnackBarCallsCount += 1
    }

    // MARK: - viewDidTapCard

    var viewDidTapCardCallsCount = 0
    var viewDidTapCardReceivedArguments: Int?
    var viewDidTapCardReceivedInvocations: [Int] = []

    func viewDidTapCard(cardIndex: Int) {
        viewDidTapCardCallsCount += 1
        let arguments = cardIndex
        viewDidTapCardReceivedArguments = arguments
        viewDidTapCardReceivedInvocations.append(arguments)
    }

    // MARK: - viewDidTapAddCardCell

    var viewDidTapAddCardCellCallsCount = 0

    func viewDidTapAddCardCell() {
        viewDidTapAddCardCellCallsCount += 1
    }

    // MARK: - viewDidHideShimmer

    var viewDidHideShimmerCallsCount = 0
    var viewDidHideShimmerReceivedArguments: Result<[PaymentCard], Error>?
    var viewDidHideShimmerReceivedInvocations: [Result<[PaymentCard], Error>] = []

    func viewDidHideShimmer(fetchCardsResult: Result<[PaymentCard], Error>) {
        viewDidHideShimmerCallsCount += 1
        let arguments = fetchCardsResult
        viewDidHideShimmerReceivedArguments = arguments
        viewDidHideShimmerReceivedInvocations.append(arguments)
    }

    // MARK: - viewDidShowAddedCardSnackbar

    var viewDidShowAddedCardSnackbarCallsCount = 0

    func viewDidShowAddedCardSnackbar() {
        viewDidShowAddedCardSnackbarCallsCount += 1
    }
}
