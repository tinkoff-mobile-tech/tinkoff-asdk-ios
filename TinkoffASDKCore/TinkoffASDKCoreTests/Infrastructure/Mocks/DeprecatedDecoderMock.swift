//
//  DeprecatedDecoderMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 24.10.2022.
//

import Foundation
@testable import TinkoffASDKCore

final class DeprecatedDecoder: IDeprecatedDecoder {
    var invokedDecode = false
    var invokedDecodeCount = 0
    var invokedDecodeParameters: (data: Data, response: HTTPURLResponse?)?
    var invokedDecodeParametersList = [(data: Data, response: HTTPURLResponse?)]()
    var stubbedDecodeError: Error?
    var stubbedDecodeResult: Any!

    func decode<Response: ResponseOperation>(data: Data, with response: HTTPURLResponse?) throws -> Response {
        invokedDecode = true
        invokedDecodeCount += 1
        invokedDecodeParameters = (data, response)
        invokedDecodeParametersList.append((data, response))
        if let error = stubbedDecodeError {
            throw error
        }
        return stubbedDecodeResult as! Response
    }
}
