//
//  URLProviderMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 20.07.2023.
//

import Foundation
@testable import TinkoffASDKCore

final class URLProviderMock: IURLProvider {

    var url: URL {
        get { return underlyingUrl }
        set(value) { underlyingUrl = value }
    }

    var underlyingUrl: URL!
}
