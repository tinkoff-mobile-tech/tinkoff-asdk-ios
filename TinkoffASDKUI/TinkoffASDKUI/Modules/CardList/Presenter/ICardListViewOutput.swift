//
//  ICardListViewOutput.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 22.02.2023.
//

import Foundation
import TinkoffASDKCore

protocol ICardListViewOutput: AnyObject {
    func viewDidLoad()
    func view(didTapDeleteOn card: CardList.Card)
    func viewDidTapEditButton()
    func viewDidTapDoneEditingButton()
    func viewDidHideRemovingCardSnackBar()
    func viewDidTapCard(cardIndex: Int)
    func viewDidTapAddCardCell()
    func viewDidHideShimmer(fetchCardsResult: Result<[PaymentCard], Error>)
    func viewDidShowAddedCardSnackbar()
}
