//
//  XCTestCase+AllureId.swift
//  UITests
//
//  Created by Andrey Belyaev on 10.10.2022.
//

import UITestUtils
import XCTest

extension XCTestCase {
    @discardableResult
    func allureId(_ value: Int) -> XCTest {
        return allureId(String(value))
    }
}
