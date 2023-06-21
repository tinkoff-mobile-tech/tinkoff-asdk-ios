//
//  AcquiringTinkoffPayServiceMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 29.05.2023.
//

import Foundation
import TinkoffASDKCore
@testable import TinkoffASDKUI

extension GetTinkoffLinkPayload {
    static func fake() -> GetTinkoffLinkPayload {
        GetTinkoffLinkPayload(redirectUrl: URL.empty)
    }
}

final class AcquiringTinkoffPayServiceMock: IAcquiringTinkoffPayService {
    var invokedGetTinkoffPayLink = false
    var invokedGetTinkoffPayLinkCount = 0
    var invokedGetTinkoffPayLinkParameters: (data: GetTinkoffLinkData, Void)?
    var invokedGetTinkoffPayLinkParametersList = [(data: GetTinkoffLinkData, Void)]()
    var stubbedGetTinkoffPayLinkCompletion: Result<GetTinkoffLinkPayload, Error>?

    func getTinkoffPayLink(
        data: TinkoffASDKCore.GetTinkoffLinkData,
        completion: @escaping (Result<TinkoffASDKCore.GetTinkoffLinkPayload, Error>) -> Void
    ) -> TinkoffASDKCore.Cancellable {
        invokedGetTinkoffPayLink = true
        invokedGetTinkoffPayLinkCount += 1
        invokedGetTinkoffPayLinkParameters = (data, ())
        invokedGetTinkoffPayLinkParametersList.append((data, ()))
        if let stubbedCompletion = stubbedGetTinkoffPayLinkCompletion {
            completion(stubbedCompletion)
        }
        return CancellableMock()
    }

    var invokedGetTinkoffPayStatus = false
    var invokedGetTinkoffPayStatusCount = 0
    var stubbedGetTinkoffPayStatusCompletion: Result<GetTinkoffPayStatusPayload, Error>?

    func getTinkoffPayStatus(
        completion: @escaping (Result<TinkoffASDKCore.GetTinkoffPayStatusPayload, Error>) -> Void
    ) -> TinkoffASDKCore.Cancellable {
        invokedGetTinkoffPayStatus = true
        invokedGetTinkoffPayStatusCount += 1
        if let stubbedCompletion = stubbedGetTinkoffPayStatusCompletion {
            completion(stubbedCompletion)
        }
        return CancellableMock()
    }
}
