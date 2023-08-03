//
//  AcquiringDecoderMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 24.10.2022.
//

import Foundation
@testable import TinkoffASDKCore

final class AcquiringDecoderMock: IAcquiringDecoder {

    // MARK: - decode<Payload Decodable>

    typealias DecodeArguments = (type: Any, data: Data, strategy: AcquiringDecodingStrategy)

    var decodeThrowableError: Error?
    var decodeCallsCount = 0
    var decodeReceivedArguments: DecodeArguments?
    var decodeReceivedInvocations: [DecodeArguments?] = []
    var decodeReturnValue: Any = EmptyDecodable()

    func decode<Payload: Decodable>(_ type: Payload.Type, from data: Data, with strategy: AcquiringDecodingStrategy) throws -> Payload {
        if let error = decodeThrowableError {
            throw error
        }
        decodeCallsCount += 1
        let arguments = (type, data, strategy)
        decodeReceivedArguments = arguments
        decodeReceivedInvocations.append(arguments)
        return decodeReturnValue as! Payload
    }
}

// MARK: - Resets

extension AcquiringDecoderMock {
    func fullReset() {
        decodeThrowableError = nil
        decodeCallsCount = 0
        decodeReceivedArguments = nil
        decodeReceivedInvocations = []
    }
}
