//
//  AddNewCardPresenterOutputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 27.03.2023.
//

@testable import TinkoffASDKUI

final class AddNewCardPresenterOutputMock: IAddNewCardPresenterOutput {

    // MARK: - addNewCardDidReceive

    var addNewCardDidReceiveCallsCount = 0
    var addNewCardDidReceiveReceivedArguments: AddCardResult?
    var addNewCardDidReceiveReceivedInvocations: [AddCardResult] = []

    func addNewCardDidReceive(result: AddCardResult) {
        addNewCardDidReceiveCallsCount += 1
        let arguments = result
        addNewCardDidReceiveReceivedArguments = arguments
        addNewCardDidReceiveReceivedInvocations.append(arguments)
    }

    // MARK: - addNewCardWasClosed

    var addNewCardWasClosedCallsCount = 0
    var addNewCardWasClosedReceivedArguments: AddCardResult?
    var addNewCardWasClosedReceivedInvocations: [AddCardResult] = []

    func addNewCardWasClosed(with result: AddCardResult) {
        addNewCardWasClosedCallsCount += 1
        let arguments = result
        addNewCardWasClosedReceivedArguments = arguments
        addNewCardWasClosedReceivedInvocations.append(arguments)
    }
}
