//
//  URLRequestBuilderMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 10.10.2022.
//

import Foundation
@testable import TinkoffASDKCore

final class URLRequestBuilderMock: IURLRequestBuilder {
    var invokedBuild = false
    var invokedBuildCount = 0
    var invokedBuildParameters: (request: NetworkRequest, Void)?
    var invokedBuildParametersList = [(request: NetworkRequest, Void)]()
    var stubbedBuildError: Error?
    var stubbedBuildResult: URLRequest = .init(url: .doesNotMatter)

    func build(request: NetworkRequest) throws -> URLRequest {
        invokedBuild = true
        invokedBuildCount += 1
        invokedBuildParameters = (request, ())
        invokedBuildParametersList.append((request, ()))
        if let error = stubbedBuildError {
            throw error
        }
        return stubbedBuildResult
    }
}
