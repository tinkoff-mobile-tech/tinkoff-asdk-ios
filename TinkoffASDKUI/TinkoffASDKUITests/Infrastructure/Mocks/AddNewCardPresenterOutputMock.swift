//
//  AddNewCardPresenterOutputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 27.03.2023.
//

@testable import TinkoffASDKUI

final class AddNewCardPresenterOutputMock: IAddNewCardPresenterOutput {

    // MARK: - addNewCardDidReceive

    typealias AddNewCardDidReceiveArguments = AddCardResult

    var addNewCardDidReceiveCallsCount = 0
    var addNewCardDidReceiveReceivedArguments: AddNewCardDidReceiveArguments?
    var addNewCardDidReceiveReceivedInvocations: [AddNewCardDidReceiveArguments?] = []

    func addNewCardDidReceive(result: AddCardResult) {
        addNewCardDidReceiveCallsCount += 1
        let arguments = result
        addNewCardDidReceiveReceivedArguments = arguments
        addNewCardDidReceiveReceivedInvocations.append(arguments)
    }

    // MARK: - addNewCardWasClosed

    typealias AddNewCardWasClosedArguments = AddCardResult

    var addNewCardWasClosedCallsCount = 0
    var addNewCardWasClosedReceivedArguments: AddNewCardWasClosedArguments?
    var addNewCardWasClosedReceivedInvocations: [AddNewCardWasClosedArguments?] = []

    func addNewCardWasClosed(with result: AddCardResult) {
        addNewCardWasClosedCallsCount += 1
        let arguments = result
        addNewCardWasClosedReceivedArguments = arguments
        addNewCardWasClosedReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension AddNewCardPresenterOutputMock {
    func fullReset() {
        addNewCardDidReceiveCallsCount = 0
        addNewCardDidReceiveReceivedArguments = nil
        addNewCardDidReceiveReceivedInvocations = []

        addNewCardWasClosedCallsCount = 0
        addNewCardWasClosedReceivedArguments = nil
        addNewCardWasClosedReceivedInvocations = []
    }
}
