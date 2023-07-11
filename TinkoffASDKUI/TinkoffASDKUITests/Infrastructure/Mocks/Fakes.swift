//
//  Fakes.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 11.07.2023.
//

import Foundation
import TinkoffASDKCore
@testable import TinkoffASDKUI

extension GetTinkoffLinkPayload {
    static func fake() -> GetTinkoffLinkPayload {
        GetTinkoffLinkPayload(redirectUrl: URL.empty)
    }
}
