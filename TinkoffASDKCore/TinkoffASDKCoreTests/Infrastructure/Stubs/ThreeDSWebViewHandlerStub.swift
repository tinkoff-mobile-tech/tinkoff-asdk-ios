//
//  ThreeDSWebViewHandlerStub.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 26.07.2023.
//

import Foundation
@testable import TinkoffASDKCore

final class ThreeDSWebViewHandlerStub: IThreeDSWebViewHandler {
    func handle<Payload>(
        urlString: String,
        responseData data: Data
    ) -> TinkoffASDKCore.ThreeDSWebViewHandlingResult<Payload>? where Payload: Decodable {
        nil
    }
}
