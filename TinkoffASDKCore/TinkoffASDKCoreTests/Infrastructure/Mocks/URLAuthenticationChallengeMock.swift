//
//  URLAuthenticationChallengeMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 01.08.2023.
//

import Foundation
@testable import TinkoffASDKCore

public final class URLAuthenticationChallengeMock: IURLAuthenticationChallenge {
    public var internalServerTrust: SecTrust? = TestTrusts.trust

    public var protectionSpace: URLProtectionSpace {
        let protectionSpace = URLProtectionSpaceMock.fake()
        protectionSpace.internalServerTrust = internalServerTrust
        return protectionSpace
    }
}
