//
//  AcquiringThreeDSServiceMock.swift
//  Pods
//
//  Created by Ivan Glushko on 19.10.2022.
//

import Foundation
@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

final class AcquiringThreeDSServiceMock: IAcquiringThreeDSService {

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

    // MARK: - confirmation3DSTerminationURL

    var confirmation3DSTerminationURLCallsCount = 0
    var confirmation3DSTerminationURLReturnValue: URL = .fakeVK

    func confirmation3DSTerminationURL() -> URL {
        confirmation3DSTerminationURLCallsCount += 1
        return confirmation3DSTerminationURLReturnValue
    }

    // MARK: - confirmation3DSTerminationV2URL

    var confirmation3DSTerminationV2URLCallsCount = 0
    var confirmation3DSTerminationV2URLReturnValue: URL = .fakeVK

    func confirmation3DSTerminationV2URL() -> URL {
        confirmation3DSTerminationV2URLCallsCount += 1
        return confirmation3DSTerminationV2URLReturnValue
    }

    // MARK: - confirmation3DSCompleteV2URL

    var confirmation3DSCompleteV2URLCallsCount = 0
    var confirmation3DSCompleteV2URLReturnValue: URL = .fakeVK

    func confirmation3DSCompleteV2URL() -> URL {
        confirmation3DSCompleteV2URLCallsCount += 1
        return confirmation3DSCompleteV2URLReturnValue
    }

    // MARK: - createChecking3DSURL

    typealias CreateChecking3DSURLArguments = Checking3DSURLData

    var createChecking3DSURLThrowableError: Error?
    var createChecking3DSURLCallsCount = 0
    var createChecking3DSURLReceivedArguments: CreateChecking3DSURLArguments?
    var createChecking3DSURLReceivedInvocations: [CreateChecking3DSURLArguments?] = []
    var createChecking3DSURLReturnValue: URLRequest = .fake

    func createChecking3DSURL(data: Checking3DSURLData) throws -> URLRequest {
        if let error = createChecking3DSURLThrowableError {
            throw error
        }
        createChecking3DSURLCallsCount += 1
        let arguments = data
        createChecking3DSURLReceivedArguments = arguments
        createChecking3DSURLReceivedInvocations.append(arguments)
        return createChecking3DSURLReturnValue
    }

    // MARK: - createConfirmation3DSRequest

    typealias CreateConfirmation3DSRequestArguments = Confirmation3DSData

    var createConfirmation3DSRequestThrowableError: Error?
    var createConfirmation3DSRequestCallsCount = 0
    var createConfirmation3DSRequestReceivedArguments: CreateConfirmation3DSRequestArguments?
    var createConfirmation3DSRequestReceivedInvocations: [CreateConfirmation3DSRequestArguments?] = []
    var createConfirmation3DSRequestReturnValue: URLRequest!

    func createConfirmation3DSRequest(data: Confirmation3DSData) throws -> URLRequest {
        if let error = createConfirmation3DSRequestThrowableError {
            throw error
        }
        createConfirmation3DSRequestCallsCount += 1
        let arguments = data
        createConfirmation3DSRequestReceivedArguments = arguments
        createConfirmation3DSRequestReceivedInvocations.append(arguments)
        return createConfirmation3DSRequestReturnValue
    }

    // MARK: - createConfirmation3DSRequestACS

    typealias CreateConfirmation3DSRequestACSArguments = (data: Confirmation3DSDataACS, messageVersion: String)

    var createConfirmation3DSRequestACSThrowableError: Error?
    var createConfirmation3DSRequestACSCallsCount = 0
    var createConfirmation3DSRequestACSReceivedArguments: CreateConfirmation3DSRequestACSArguments?
    var createConfirmation3DSRequestACSReceivedInvocations: [CreateConfirmation3DSRequestACSArguments?] = []
    var createConfirmation3DSRequestACSReturnValue: URLRequest!

    func createConfirmation3DSRequestACS(data: Confirmation3DSDataACS, messageVersion: String) throws -> URLRequest {
        if let error = createConfirmation3DSRequestACSThrowableError {
            throw error
        }
        createConfirmation3DSRequestACSCallsCount += 1
        let arguments = (data, messageVersion)
        createConfirmation3DSRequestACSReceivedArguments = arguments
        createConfirmation3DSRequestACSReceivedInvocations.append(arguments)
        return createConfirmation3DSRequestACSReturnValue
    }

    // MARK: - submit3DSAuthorizationV2

    typealias Submit3DSAuthorizationV2Arguments = (data: CresData, completion: (_ result: Result<GetPaymentStatePayload, Error>) -> Void)

    var submit3DSAuthorizationV2CallsCount = 0
    var submit3DSAuthorizationV2ReceivedArguments: Submit3DSAuthorizationV2Arguments?
    var submit3DSAuthorizationV2ReceivedInvocations: [Submit3DSAuthorizationV2Arguments?] = []
    var submit3DSAuthorizationV2CompletionClosureInput: Result<GetPaymentStatePayload, Error>?
    var submit3DSAuthorizationV2ReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func submit3DSAuthorizationV2(data: CresData, completion: @escaping (_ result: Result<GetPaymentStatePayload, Error>) -> Void) -> Cancellable {
        submit3DSAuthorizationV2CallsCount += 1
        let arguments = (data, completion)
        submit3DSAuthorizationV2ReceivedArguments = arguments
        submit3DSAuthorizationV2ReceivedInvocations.append(arguments)
        if let submit3DSAuthorizationV2CompletionClosureInput = submit3DSAuthorizationV2CompletionClosureInput {
            completion(submit3DSAuthorizationV2CompletionClosureInput)
        }
        return submit3DSAuthorizationV2ReturnValue
    }

    // MARK: - getCertsConfig

    typealias GetCertsConfigArguments = (Result<Get3DSAppBasedCertsConfigPayload, Error>) -> Void

    var getCertsConfigCallsCount = 0
    var getCertsConfigReceivedArguments: GetCertsConfigArguments?
    var getCertsConfigReceivedInvocations: [GetCertsConfigArguments?] = []
    var getCertsConfigCompletionClosureInput: Result<Get3DSAppBasedCertsConfigPayload, Error>?
    var getCertsConfigReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func getCertsConfig(completion: @escaping (Result<Get3DSAppBasedCertsConfigPayload, Error>) -> Void) -> Cancellable {
        getCertsConfigCallsCount += 1
        let arguments = completion
        getCertsConfigReceivedArguments = arguments
        getCertsConfigReceivedInvocations.append(arguments)
        if let getCertsConfigCompletionClosureInput = getCertsConfigCompletionClosureInput {
            completion(getCertsConfigCompletionClosureInput)
        }
        return getCertsConfigReturnValue
    }
}

// MARK: - Resets

extension AcquiringThreeDSServiceMock {
    func fullReset() {
        check3DSVersionCallsCount = 0
        check3DSVersionReceivedArguments = nil
        check3DSVersionReceivedInvocations = []
        check3DSVersionCompletionClosureInput = nil

        confirmation3DSTerminationURLCallsCount = 0

        confirmation3DSTerminationV2URLCallsCount = 0

        confirmation3DSCompleteV2URLCallsCount = 0

        createChecking3DSURLThrowableError = nil
        createChecking3DSURLCallsCount = 0
        createChecking3DSURLReceivedArguments = nil
        createChecking3DSURLReceivedInvocations = []

        createConfirmation3DSRequestThrowableError = nil
        createConfirmation3DSRequestCallsCount = 0
        createConfirmation3DSRequestReceivedArguments = nil
        createConfirmation3DSRequestReceivedInvocations = []

        createConfirmation3DSRequestACSThrowableError = nil
        createConfirmation3DSRequestACSCallsCount = 0
        createConfirmation3DSRequestACSReceivedArguments = nil
        createConfirmation3DSRequestACSReceivedInvocations = []

        submit3DSAuthorizationV2CallsCount = 0
        submit3DSAuthorizationV2ReceivedArguments = nil
        submit3DSAuthorizationV2ReceivedInvocations = []
        submit3DSAuthorizationV2CompletionClosureInput = nil

        getCertsConfigCallsCount = 0
        getCertsConfigReceivedArguments = nil
        getCertsConfigReceivedInvocations = []
        getCertsConfigCompletionClosureInput = nil
    }
}
