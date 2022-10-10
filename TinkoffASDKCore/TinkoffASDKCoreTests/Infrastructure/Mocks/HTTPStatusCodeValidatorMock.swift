//
//  HTTPStatusCodeValidatorMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 10.10.2022.
//

import Foundation
@testable import TinkoffASDKCore

final class HTTPStatusCodeValidatorMock: IHTTPStatusCodeValidator {
    var invokedValidate = false
    var invokedValidateCount = 0
    var invokedValidateParameters: (statusCode: Int, Void)?
    var invokedValidateParametersList = [(statusCode: Int, Void)]()
    var stubbedValidateResult: Bool! = false

    func validate(statusCode: Int) -> Bool {
        invokedValidate = true
        invokedValidateCount += 1
        invokedValidateParameters = (statusCode, ())
        invokedValidateParametersList.append((statusCode, ()))
        return stubbedValidateResult
    }
}
