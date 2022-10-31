//
//  AcquiringRequestAdapterMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 24.10.2022.
//

import Foundation
@testable import TinkoffASDKCore

final class AcquiringRequestAdapterMock: IAcquiringRequestAdapter {
    typealias AdaptCompletion = (Result<AcquiringRequest, Error>) -> Void

    var invokedAdapt = false
    var invokedAdaptCount = 0
    var invokedAdaptParameter: AcquiringRequest?
    var invokedAdaptParametersList = [AcquiringRequest]()
    var adaptMethodStub = { (request: AcquiringRequest, completion: @escaping AdaptCompletion) in
        completion(.success(request))
    }

    func adapt(
        request: AcquiringRequest,
        completion: @escaping (Result<AcquiringRequest, Error>) -> Void
    ) {
        invokedAdapt = true
        invokedAdaptCount += 1
        invokedAdaptParameter = request
        invokedAdaptParametersList.append(request)
        adaptMethodStub(request, completion)
    }
}
