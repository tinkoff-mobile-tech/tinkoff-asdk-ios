//
//  XCTest+Extension.swift
//  Pods
//
//  Created by Ivan Glushko on 05.05.2023.
//

import XCTest

extension XCTest {

    func XCTAssertEqualTypes<T, U>(_ first: @autoclosure () throws -> T, _ second: @autoclosure () throws -> U) {
        do {
            let firstValue = try first()
            let secondValue = try second()
            let firstMetatype = type(of: firstValue as Any)
            let secondMetatype = type(of: secondValue as Any)
            XCTAssert(
                firstMetatype == secondMetatype,
                "Type of \(firstMetatype) is not equal to \(secondMetatype)"
            )
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
