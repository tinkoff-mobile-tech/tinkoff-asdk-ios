//
//  CardScannerDelegateMock.swift
//  Pods
//
//  Created by Ivan Glushko on 31.05.2023.
//

@testable import TinkoffASDKUI
import UIKit

final class CardScannerDelegateMock: ICardScannerDelegate {
    // MARK: - cardScanButtonDidPressed

    typealias CardScanButtonDidPressedArguments = (viewController: UIViewController, completion: CardScannerCompletion)

    var cardScanButtonDidPressedCallsCount = 0
    var cardScanButtonDidPressedReceivedArguments: CardScanButtonDidPressedArguments?
    var cardScanButtonDidPressedReceivedInvocations: [CardScanButtonDidPressedArguments] = []
    var cardScanButtonDidPressedCompletionClosureInput: (String?, String?, String?)?

    func cardScanButtonDidPressed(on viewController: UIViewController, completion: @escaping CardScannerCompletion) {
        cardScanButtonDidPressedCallsCount += 1
        let arguments = (viewController, completion)
        cardScanButtonDidPressedReceivedArguments = arguments
        cardScanButtonDidPressedReceivedInvocations.append(arguments)
        if let input = cardScanButtonDidPressedCompletionClosureInput {
            completion(input.0, input.1, input.2)
        }
    }
}
