//
//  MockAddNewCardOutput.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 16.01.2023.
//

@testable import TinkoffASDKUI

final class MockAddNewCardOutput: IAddNewCardOutput {

    var addingNewCardCompletedCallCounter = 0

    var addingNewCardCompletedStub: (AddNewCardResult) -> Void = { _ in }
    func addingNewCardCompleted(result: AddNewCardResult) {
        addingNewCardCompletedCallCounter += 1
        addingNewCardCompletedStub(result)
    }
}
