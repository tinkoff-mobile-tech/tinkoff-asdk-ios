//
//  AcquiringDecoderMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 24.10.2022.
//

import Foundation
@testable import TinkoffASDKCore

final class AcquiringDecoderMock: IAcquiringDecoder {
    var invokedDecode = false
    var invokedDecodeCount = 0
    var invokedDecodeParameters: (type: Any, data: Data, strategy: AcquiringDecodingStrategy)?
    var invokedDecodeParametersList = [(type: Any, data: Data, strategy: AcquiringDecodingStrategy)]()
    var stubbedDecodeError: Error?
    var stubbedDecodeResult: Any!

    func decode<Payload: Decodable>(
        _ type: Payload.Type,
        from data: Data,
        with strategy: AcquiringDecodingStrategy
    ) throws -> Payload {
        invokedDecode = true
        invokedDecodeCount += 1
        invokedDecodeParameters = (type, data, strategy)
        invokedDecodeParametersList.append((type, data, strategy))
        if let error = stubbedDecodeError {
            throw error
        }
        return stubbedDecodeResult as! Payload
    }
}
