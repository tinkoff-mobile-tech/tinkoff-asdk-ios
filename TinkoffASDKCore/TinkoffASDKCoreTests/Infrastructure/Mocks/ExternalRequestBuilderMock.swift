//
//  ExternalRequestBuilderMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 26.07.2023.
//

import Foundation
@testable import TinkoffASDKCore

final class ExternalRequestBuilderMock: IExternalRequestBuilder {

    // MARK: - get3DSAppBasedConfigRequest

    var get3DSAppBasedConfigRequestCallsCount = 0
    var get3DSAppBasedConfigRequestReturnValue: NetworkRequest!

    func get3DSAppBasedConfigRequest() -> NetworkRequest {
        get3DSAppBasedConfigRequestCallsCount += 1
        return get3DSAppBasedConfigRequestReturnValue
    }

    // MARK: - getSBPBanks

    var getSBPBanksCallsCount = 0
    var getSBPBanksReturnValue: NetworkRequest!

    func getSBPBanks() -> NetworkRequest {
        getSBPBanksCallsCount += 1
        return getSBPBanksReturnValue
    }
}

// MARK: - Resets

extension ExternalRequestBuilderMock {
    func fullReset() {
        get3DSAppBasedConfigRequestCallsCount = 0

        getSBPBanksCallsCount = 0
    }
}
