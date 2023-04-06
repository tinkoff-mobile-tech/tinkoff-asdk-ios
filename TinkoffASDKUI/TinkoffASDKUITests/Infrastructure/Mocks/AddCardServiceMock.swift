//
//  AddCardServiceMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 27.03.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

public final class AddCardServiceMock: IAddCardService {

    public init() {}

    // MARK: - addCard

    public typealias AddCardArguments = (data: AddCardData, completion: (_ result: Result<AddCardPayload, Error>) -> Void)

    public var addCardCallsCount = 0
    public var addCardReceivedArguments: AddCardArguments?
    public var addCardReceivedInvocations: [AddCardArguments] = []
    public var addCardCompletionStub: Result<AddCardPayload, Error>?
    public var addCardReturnValue: Cancellable!

    @discardableResult
    public func addCard(data: AddCardData, completion: @escaping (_ result: Result<AddCardPayload, Error>) -> Void) -> Cancellable {
        addCardCallsCount += 1
        let arguments = (data, completion)
        addCardReceivedArguments = arguments
        addCardReceivedInvocations.append(arguments)
        if let addCardCompletionStub = addCardCompletionStub {
            completion(addCardCompletionStub)
        }
        return addCardReturnValue
    }

    // MARK: - check3DSVersion

    public typealias Check3DSVersionArguments = (data: Check3DSVersionData, completion: (_ result: Result<Check3DSVersionPayload, Error>) -> Void)

    public var check3DSVersionCallsCount = 0
    public var check3DSVersionReceivedArguments: Check3DSVersionArguments?
    public var check3DSVersionReceivedInvocations: [Check3DSVersionArguments] = []
    public var check3DSVersionCompletionStub: Result<Check3DSVersionPayload, Error>?
    public var check3DSVersionReturnValue: Cancellable!

    @discardableResult
    public func check3DSVersion(data: Check3DSVersionData, completion: @escaping (_ result: Result<Check3DSVersionPayload, Error>) -> Void) -> Cancellable {
        check3DSVersionCallsCount += 1
        let arguments = (data, completion)
        check3DSVersionReceivedArguments = arguments
        check3DSVersionReceivedInvocations.append(arguments)
        if let check3DSVersionCompletionStub = check3DSVersionCompletionStub {
            completion(check3DSVersionCompletionStub)
        }
        return check3DSVersionReturnValue
    }

    // MARK: - attachCard

    public typealias AttachCardArguments = (data: AttachCardData, completion: (_ result: Result<AttachCardPayload, Error>) -> Void)

    public var attachCardCallsCount = 0
    public var attachCardReceivedArguments: AttachCardArguments?
    public var attachCardCompletionStub: Result<AttachCardPayload, Error>?
    public var attachCardReceivedInvocations: [AttachCardArguments] = []
    public var attachCardReturnValue: Cancellable!

    @discardableResult
    public func attachCard(data: AttachCardData, completion: @escaping (_ result: Result<AttachCardPayload, Error>) -> Void) -> Cancellable {
        attachCardCallsCount += 1
        let arguments = (data, completion)
        attachCardReceivedArguments = arguments
        attachCardReceivedInvocations.append(arguments)
        if let attachCardCompletionStub = attachCardCompletionStub {
            completion(attachCardCompletionStub)
        }
        return attachCardReturnValue
    }

    // MARK: - getAddCardState

    public typealias GetAddCardStateArguments = (data: GetAddCardStateData, completion: (Result<GetAddCardStatePayload, Error>) -> Void)

    public var getAddCardStateCallsCount = 0
    public var getAddCardStateReceivedArguments: GetAddCardStateArguments?
    public var getAddCardStateReceivedInvocations: [GetAddCardStateArguments] = []
    public var getAddCardStateReturnValue: Cancellable!

    @discardableResult
    public func getAddCardState(data: GetAddCardStateData, completion: @escaping (Result<GetAddCardStatePayload, Error>) -> Void) -> Cancellable {
        getAddCardStateCallsCount += 1
        let arguments = (data, completion)
        getAddCardStateReceivedArguments = arguments
        getAddCardStateReceivedInvocations.append(arguments)
        return getAddCardStateReturnValue
    }
}
