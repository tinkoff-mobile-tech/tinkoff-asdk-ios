//
//  Bundle+TestResources.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 30.11.2022.
//

import Foundation

extension Bundle {
    private final class Token {}

    static var testResources: Bundle {
        #if SWIFT_PACKAGE
            .module
        #else
            Bundle(for: Token.self)
        #endif
    }
}
