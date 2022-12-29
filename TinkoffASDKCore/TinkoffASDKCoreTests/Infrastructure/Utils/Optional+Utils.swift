//
//  Optional+Utils.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 25.10.2022.
//

import Foundation
import XCTest

extension Optional {
    func xctUnwrapped(
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Wrapped {
        try XCTUnwrap(self, message(), file: file, line: line)
    }
}
