//
//  CardListViewOutputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 24.03.2023
//

import Foundation
import TinkoffASDKCore
@testable import TinkoffASDKUI

final class CardListViewOutputMock: ICardListViewOutput {

    // MARK: - viewDidLoad

    var viewDidLoadCallsCount = 0

    func viewDidLoad() {
        viewDidLoadCallsCount += 1
    }

    // MARK: - view

    typealias ViewArguments = CardList.Card

    var viewCallsCount = 0
    var viewReceivedArguments: ViewArguments?
    var viewReceivedInvocations: [ViewArguments?] = []

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

    typealias ViewDidTapCardArguments = Int

    var viewDidTapCardCallsCount = 0
    var viewDidTapCardReceivedArguments: ViewDidTapCardArguments?
    var viewDidTapCardReceivedInvocations: [ViewDidTapCardArguments?] = []

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

    typealias ViewDidHideShimmerArguments = Result<[PaymentCard], Error>

    var viewDidHideShimmerCallsCount = 0
    var viewDidHideShimmerReceivedArguments: ViewDidHideShimmerArguments?
    var viewDidHideShimmerReceivedInvocations: [ViewDidHideShimmerArguments?] = []

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

// MARK: - Resets

extension CardListViewOutputMock {
    func fullReset() {
        viewDidLoadCallsCount = 0

        viewCallsCount = 0
        viewReceivedArguments = nil
        viewReceivedInvocations = []

        viewDidTapEditButtonCallsCount = 0

        viewDidTapDoneEditingButtonCallsCount = 0

        viewDidHideRemovingCardSnackBarCallsCount = 0

        viewDidTapCardCallsCount = 0
        viewDidTapCardReceivedArguments = nil
        viewDidTapCardReceivedInvocations = []

        viewDidTapAddCardCellCallsCount = 0

        viewDidHideShimmerCallsCount = 0
        viewDidHideShimmerReceivedArguments = nil
        viewDidHideShimmerReceivedInvocations = []

        viewDidShowAddedCardSnackbarCallsCount = 0
    }
}
