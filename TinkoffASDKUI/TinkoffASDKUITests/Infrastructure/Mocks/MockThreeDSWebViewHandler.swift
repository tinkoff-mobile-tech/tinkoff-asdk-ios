//
//  MockThreeDSWebViewHandler.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 17.10.2022.
//

import Foundation
@testable import TinkoffASDKCore

final class MockThreeDSWebViewHandler: IThreeDSWebViewHandler {

    var didCancel: (() -> Void)?

    // MARK: - Handle

    struct HandlePassedArguments {
        let urlString: String
        let responseData: Data
    }

    var handleCallCounter = 0
    var handlePassedArguments: HandlePassedArguments?
    var handleReturnStubValue: Result<Decodable, Error> = .failure(TestsError.noValue)

    func handle<Payload: Decodable>(
        urlString: String,
        responseData data: Data
    ) throws -> Payload {
        handleCallCounter += 1
        handlePassedArguments = HandlePassedArguments(
            urlString: urlString,
            responseData: data
        )

        return try (handleReturnStubValue as! Result<Payload, Error>).get()
    }
}
