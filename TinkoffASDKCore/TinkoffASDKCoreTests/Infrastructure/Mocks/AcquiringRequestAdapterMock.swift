//
//  AcquiringRequestAdapterMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 24.10.2022.
//

import Foundation
@testable import TinkoffASDKCore

final class AcquiringRequestAdapterMock: IAcquiringRequestAdapter {
    var invokedAdapt = false
    var invokedAdaptCount = 0
    var invokedAdaptParameters: (request: AcquiringRequest, Void)?
    var invokedAdaptParametersList = [(request: AcquiringRequest, Void)]()
    var stubbedAdaptCompletionResult: (Result<AcquiringRequest, Error>, Void)?

    func adapt(
        request: AcquiringRequest,
        completion: @escaping (Result<AcquiringRequest, Error>) -> Void
    ) {
        invokedAdapt = true
        invokedAdaptCount += 1
        invokedAdaptParameters = (request, ())
        invokedAdaptParametersList.append((request, ()))
        if let result = stubbedAdaptCompletionResult {
            completion(result.0)
        }
    }
}
