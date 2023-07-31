//
//  AddCardServiceMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 27.03.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class AddCardServiceMock: IAddCardService {

    // MARK: - addCard

    typealias AddCardArguments = (data: AddCardData, completion: (_ result: Result<AddCardPayload, Error>) -> Void)

    var addCardCallsCount = 0
    var addCardReceivedArguments: AddCardArguments?
    var addCardReceivedInvocations: [AddCardArguments?] = []
    var addCardCompletionClosureInput: Result<AddCardPayload, Error>?
    var addCardReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func addCard(data: AddCardData, completion: @escaping (_ result: Result<AddCardPayload, Error>) -> Void) -> Cancellable {
        addCardCallsCount += 1
        let arguments = (data, completion)
        addCardReceivedArguments = arguments
        addCardReceivedInvocations.append(arguments)
        if let addCardCompletionClosureInput = addCardCompletionClosureInput {
            completion(addCardCompletionClosureInput)
        }
        return addCardReturnValue
    }

    // MARK: - check3DSVersion

    typealias Check3DSVersionArguments = (data: Check3DSVersionData, completion: (_ result: Result<Check3DSVersionPayload, Error>) -> Void)

    var check3DSVersionCallsCount = 0
    var check3DSVersionReceivedArguments: Check3DSVersionArguments?
    var check3DSVersionReceivedInvocations: [Check3DSVersionArguments?] = []
    var check3DSVersionCompletionClosureInput: Result<Check3DSVersionPayload, Error>?
    var check3DSVersionReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func check3DSVersion(data: Check3DSVersionData, completion: @escaping (_ result: Result<Check3DSVersionPayload, Error>) -> Void) -> Cancellable {
        check3DSVersionCallsCount += 1
        let arguments = (data, completion)
        check3DSVersionReceivedArguments = arguments
        check3DSVersionReceivedInvocations.append(arguments)
        if let check3DSVersionCompletionClosureInput = check3DSVersionCompletionClosureInput {
            completion(check3DSVersionCompletionClosureInput)
        }
        return check3DSVersionReturnValue
    }

    // MARK: - attachCard

    typealias AttachCardArguments = (data: AttachCardData, completion: (_ result: Result<AttachCardPayload, Error>) -> Void)

    var attachCardCallsCount = 0
    var attachCardReceivedArguments: AttachCardArguments?
    var attachCardReceivedInvocations: [AttachCardArguments?] = []
    var attachCardCompletionClosureInput: Result<AttachCardPayload, Error>?
    var attachCardReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func attachCard(data: AttachCardData, completion: @escaping (_ result: Result<AttachCardPayload, Error>) -> Void) -> Cancellable {
        attachCardCallsCount += 1
        let arguments = (data, completion)
        attachCardReceivedArguments = arguments
        attachCardReceivedInvocations.append(arguments)
        if let attachCardCompletionClosureInput = attachCardCompletionClosureInput {
            completion(attachCardCompletionClosureInput)
        }
        return attachCardReturnValue
    }

    // MARK: - getAddCardState

    typealias GetAddCardStateArguments = (data: GetAddCardStateData, completion: (Result<GetAddCardStatePayload, Error>) -> Void)

    var getAddCardStateCallsCount = 0
    var getAddCardStateReceivedArguments: GetAddCardStateArguments?
    var getAddCardStateReceivedInvocations: [GetAddCardStateArguments?] = []
    var getAddCardStateCompletionClosureInput: Result<GetAddCardStatePayload, Error>?
    var getAddCardStateReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func getAddCardState(data: GetAddCardStateData, completion: @escaping (Result<GetAddCardStatePayload, Error>) -> Void) -> Cancellable {
        getAddCardStateCallsCount += 1
        let arguments = (data, completion)
        getAddCardStateReceivedArguments = arguments
        getAddCardStateReceivedInvocations.append(arguments)
        if let getAddCardStateCompletionClosureInput = getAddCardStateCompletionClosureInput {
            completion(getAddCardStateCompletionClosureInput)
        }
        return getAddCardStateReturnValue
    }
}

// MARK: - Resets

extension AddCardServiceMock {
    func fullReset() {
        addCardCallsCount = 0
        addCardReceivedArguments = nil
        addCardReceivedInvocations = []
        addCardCompletionClosureInput = nil

        check3DSVersionCallsCount = 0
        check3DSVersionReceivedArguments = nil
        check3DSVersionReceivedInvocations = []
        check3DSVersionCompletionClosureInput = nil

        attachCardCallsCount = 0
        attachCardReceivedArguments = nil
        attachCardReceivedInvocations = []
        attachCardCompletionClosureInput = nil

        getAddCardStateCallsCount = 0
        getAddCardStateReceivedArguments = nil
        getAddCardStateReceivedInvocations = []
        getAddCardStateCompletionClosureInput = nil
    }
}
