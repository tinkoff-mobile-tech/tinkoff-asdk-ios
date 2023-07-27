//
//  AddNewCardAssemblyMock.swift
//  Pods
//
//  Created by Ivan Glushko on 25.05.2023.
//

@testable import TinkoffASDKUI
import UIKit

final class AddNewCardAssemblyMock: IAddNewCardAssembly {

    // MARK: - addNewCardView

    typealias AddNewCardViewArguments = (customerKey: String, output: IAddNewCardPresenterOutput?, cardScannerDelegate: ICardScannerDelegate?)

    var addNewCardViewCallsCount = 0
    var addNewCardViewReceivedArguments: AddNewCardViewArguments?
    var addNewCardViewReceivedInvocations: [AddNewCardViewArguments?] = []
    var addNewCardViewReturnValue: AddNewCardViewController!

    func addNewCardView(customerKey: String, output: IAddNewCardPresenterOutput?, cardScannerDelegate: ICardScannerDelegate?) -> AddNewCardViewController {
        addNewCardViewCallsCount += 1
        let arguments = (customerKey, output, cardScannerDelegate)
        addNewCardViewReceivedArguments = arguments
        addNewCardViewReceivedInvocations.append(arguments)
        return addNewCardViewReturnValue
    }

    // MARK: - addNewCardNavigationController

    typealias AddNewCardNavigationControllerArguments = (customerKey: String, cardScannerDelegate: ICardScannerDelegate?, onViewWasClosed: ((AddCardResult) -> Void)?)

    var addNewCardNavigationControllerCallsCount = 0
    var addNewCardNavigationControllerReceivedArguments: AddNewCardNavigationControllerArguments?
    var addNewCardNavigationControllerReceivedInvocations: [AddNewCardNavigationControllerArguments?] = []
    var addNewCardNavigationControllerOnViewWasClosedClosureInput: AddCardResult?
    var addNewCardNavigationControllerReturnValue: UINavigationController!

    func addNewCardNavigationController(customerKey: String, cardScannerDelegate: ICardScannerDelegate?, onViewWasClosed: ((AddCardResult) -> Void)?) -> UINavigationController {
        addNewCardNavigationControllerCallsCount += 1
        let arguments = (customerKey, cardScannerDelegate, onViewWasClosed)
        addNewCardNavigationControllerReceivedArguments = arguments
        addNewCardNavigationControllerReceivedInvocations.append(arguments)
        if let addNewCardNavigationControllerOnViewWasClosedClosureInput = addNewCardNavigationControllerOnViewWasClosedClosureInput {
            onViewWasClosed?(addNewCardNavigationControllerOnViewWasClosedClosureInput)
        }
        return addNewCardNavigationControllerReturnValue
    }
}

// MARK: - Resets

extension AddNewCardAssemblyMock {
    func fullReset() {
        addNewCardViewCallsCount = 0
        addNewCardViewReceivedArguments = nil
        addNewCardViewReceivedInvocations = []

        addNewCardNavigationControllerCallsCount = 0
        addNewCardNavigationControllerReceivedArguments = nil
        addNewCardNavigationControllerReceivedInvocations = []
        addNewCardNavigationControllerOnViewWasClosedClosureInput = nil
    }
}
