//
//
//  TDSFlowError.swift
//
//  Copyright (c) 2021 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import ThreeDSWrapper

enum TDSFlowError: Swift.Error {
    case invalidPaymentSystem
    case updatingCertsError([CertificateUpdatingRequest: TDSWrapperError])
    case timeout
}

extension TDSWrapperError: Equatable {
    public static func == (lhs: TDSWrapperError, rhs: TDSWrapperError) -> Bool {
        lhs.code == rhs.code
    }
}

extension TDSFlowError: Equatable {
    static func == (lhs: TDSFlowError, rhs: TDSFlowError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidPaymentSystem, .invalidPaymentSystem):
            return true
        case let (.updatingCertsError(lhsArray), .updatingCertsError(rhsArray)):
            return lhsArray == rhsArray
        case (.timeout, .timeout):
            return true
        default:
            return false
        }
    }
}

extension TDSFlowError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidPaymentSystem:
            return Loc.TinkoffAcquiring.Threeds.Error.invalidPaymentSystem
        case let .updatingCertsError(dictionary):
            return Loc.TinkoffAcquiring.Threeds.Error.updatingCertsError + String(describing: dictionary)
        case .timeout:
            return Loc.TinkoffAcquiring.Threeds.Error.timeout
        }
    }
}
