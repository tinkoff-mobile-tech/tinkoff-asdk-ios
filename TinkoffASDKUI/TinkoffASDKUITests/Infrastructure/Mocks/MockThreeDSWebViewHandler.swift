//
//  MockThreeDSWebViewHandler.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 17.10.2022.
//

import Foundation
@testable import TinkoffASDKCore

final class MockThreeDSWebViewHandler: IThreeDSWebViewHandler {

    var onUserTapCloseButton: (() -> Void)?

    // MARK: - Handle

    struct HandlePassedArguments {
        let urlString: String
        let responseData: Data
    }

    var handleCallCounter = 0
    var handlePassedArguments: HandlePassedArguments?
    var handleReturnStubValue: (HandlePassedArguments) -> Result<Decodable, Error> = { _ in .failure(TestsError.noValue) }

    func handle<Payload: Decodable>(
        urlString: String,
        responseData data: Data
    ) throws -> ThreeDSHandleResult<Payload> {
        handleCallCounter += 1
        let args = HandlePassedArguments(
            urlString: urlString,
            responseData: data
        )
        handlePassedArguments = args
        let payload = try handleReturnStubValue(args).get()

        return .finished(payload: payload as! Payload)
    }
}
