//
//  AcquiringThreeDsServiceMock.swift
//  Pods
//
//  Created by Ivan Glushko on 19.10.2022.
//

import Foundation
@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

extension URL {
    static let empty = URL(string: "www.vk.com")!
}

extension URLRequest {
    static let empty = URLRequest(url: .empty)
}

final class AcquiringThreeDsServiceMock: IAcquiringThreeDSService {

    // MARK: - check3DSVersion

    struct Check3DSVersionPassedArguments {
        let data: Check3DSVersionData
        let completion: (Result<Check3DSVersionPayload, Error>) -> Void
    }

    var check3DSVersionCallCounter = 0
    var check3DSVersionPassedArguments: Check3DSVersionPassedArguments?
    var check3DSVersionStubReturnValue: (Check3DSVersionPassedArguments) -> Cancellable = { _ in EmptyCancellable() }

    func check3DSVersion(data: Check3DSVersionData, completion: @escaping (Result<Check3DSVersionPayload, Error>) -> Void) -> Cancellable {
        check3DSVersionCallCounter += 1
        let args = Check3DSVersionPassedArguments(
            data: data,
            completion: completion
        )
        check3DSVersionPassedArguments = args
        return check3DSVersionStubReturnValue(args)
    }

    // MARK: - confirmation3DSTerminationURL

    var confirmation3DSTerminationURLCallCounter = 0
    var confirmation3DSTerminationURLStubReturnValue: () -> URL = { .empty }

    func confirmation3DSTerminationURL() -> URL {
        confirmation3DSTerminationURLCallCounter += 1
        return confirmation3DSTerminationURLStubReturnValue()
    }

    // MARK: - confirmation3DSTerminationV2URL

    var confirmation3DSTerminationV2URLCallCounter = 0
    var confirmation3DSTerminationV2URLStubReturnValue: () -> URL = { .empty }

    func confirmation3DSTerminationV2URL() -> URL {
        confirmation3DSTerminationV2URLCallCounter += 1
        return confirmation3DSTerminationV2URLStubReturnValue()
    }

    // MARK: - confirmation3DSCompleteV2URL

    var confirmation3DSCompleteV2URLCallCounter = 0
    var confirmation3DSCompleteV2URLStubReturnValue: () -> URL = { .empty }

    func confirmation3DSCompleteV2URL() -> URL {
        confirmation3DSCompleteV2URLCallCounter += 1
        return confirmation3DSCompleteV2URLStubReturnValue()
    }

    // MARK: - createChecking3DSURL

    struct CreateChecking3DSURLPassedArguments {
        let data: Checking3DSURLData
    }

    var createChecking3DSURLCallCounter = 0
    var createChecking3DSURLReturnStub: (CreateChecking3DSURLPassedArguments) throws -> URLRequest = { _ in .empty }

    func createChecking3DSURL(data: Checking3DSURLData) throws -> URLRequest {
        createChecking3DSURLCallCounter += 1
        let args = CreateChecking3DSURLPassedArguments(data: data)
        return try createChecking3DSURLReturnStub(args)
    }

    // MARK: - createConfirmation3DSRequest

    struct CreateConfirmation3DSRequestPassedArguments {
        let data: Confirmation3DSData
    }

    var createConfirmation3DSRequestCallCounter = 0
    var createConfirmation3DSRequestReturnStub: (CreateConfirmation3DSRequestPassedArguments) throws -> URLRequest = { _ in .empty }

    func createConfirmation3DSRequest(data: Confirmation3DSData) throws -> URLRequest {
        createConfirmation3DSRequestCallCounter += 1
        let args = CreateConfirmation3DSRequestPassedArguments(data: data)

        return try createConfirmation3DSRequestReturnStub(args)
    }

    // MARK: - createConfirmation3DSRequestACS

    struct CreateConfirmation3DSRequestACSPassedArguments {
        let data: Confirmation3DSDataACS
        let messageVersion: String
    }

    var createConfirmation3DSRequestACSCallCounter = 0

    var createConfirmation3DSRequestACSReturnStub: (CreateConfirmation3DSRequestACSPassedArguments) throws -> URLRequest = { _ in .empty }

    func createConfirmation3DSRequestACS(
        data: Confirmation3DSDataACS,
        messageVersion: String
    ) throws -> URLRequest {
        createConfirmation3DSRequestACSCallCounter += 1
        let args = CreateConfirmation3DSRequestACSPassedArguments(
            data: data,
            messageVersion: messageVersion
        )
        return try createConfirmation3DSRequestACSReturnStub(args)
    }
}
