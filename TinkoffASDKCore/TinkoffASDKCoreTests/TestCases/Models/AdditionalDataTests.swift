//
//  AdditionalDataTests.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Ivan Glushko on 04.08.2023.
//

import TinkoffASDKCore
import XCTest

final class AdditionalDataTests: BaseTestCase {

    func test_empty() {
        // given
        let empty = AdditionalData(data: [:])
        // when
        let computedEmpty = AdditionalData.empty()
        // then
        XCTAssertEqual(empty, computedEmpty)
    }

    func test_merging_equal_data() {
        // given
        var data = AdditionalData(data: TestData.firstData)
        let secondData = AdditionalData(data: TestData.firstDataDuplicate)
        // when
        data.merging(secondData)
        // then
        XCTAssertTrue(data == AdditionalData(data: TestData.firstData))
    }

    func test_merging_ovverides_data() {
        // given
        var data = AdditionalData(data: ["key": "value"])
        let secondData = AdditionalData(data: ["key": "new_value"])
        // when
        data.merging(secondData)
        // then
        XCTAssertTrue(data == secondData)
    }

    func test_merging_adds_new_data() {
        // given
        var data = AdditionalData(data: ["key": "value"])
        let secondData = AdditionalData(data: ["new": "data"])
        // when
        data.merging(secondData)
        // then
        XCTAssertEqual(data.data.keys.count, 2)
        XCTAssertEqual(data, AdditionalData(data: ["new": "data", "key": "value"]))
    }

    func test_equatable() {
        // given
        let firstData = AdditionalData(data: TestData.firstData)
        let secondData = AdditionalData(data: TestData.secondData)
        // when
        let result = firstData == secondData
        // then
        XCTAssertFalse(result)
    }

    func test_equatable_duplicates() {
        // given
        let firstData = AdditionalData(data: TestData.firstData)
        let duplicateData = AdditionalData(data: TestData.firstDataDuplicate)
        // when
        let result = firstData == duplicateData
        // then
        XCTAssertTrue(result)
    }

    func test_equatable_for_related_classes() {
        let firstData = AdditionalData(data: ["key": "value", "object": TestData.Parent()])
        let secondData = AdditionalData(data: ["key": "value", "object": TestData.Child()])
        // when
        let result = firstData == secondData
        // then
        XCTAssertTrue(result)
    }

    func test_equatable_for_unrelated_classes() {
        let firstData = AdditionalData(data: ["key": "value", "object": TestData.Parent()])
        let secondData = AdditionalData(data: ["key": "value", "object": TestData.ParentCopyCat()])
        // when
        let result = firstData == secondData
        // then
        XCTAssertFalse(result)
    }
}

private struct TestData {
    static let firstData = [
        "key": "value",
        "isHappy": "true",
        "number": "1234",
    ]

    static let firstDataDuplicate = [
        "key": "value",
        "isHappy": "true",
        "number": "1234",
    ]

    static let secondData = [
        "key": "value",
        "isHappy": "true",
        "number": "1234",
        "hair": "brown",
    ]

    class Parent: Encodable, Equatable {
        let name = "Ivan"

        static func == (lhs: TestData.Parent, rhs: TestData.Parent) -> Bool {
            lhs.name == rhs.name
        }
    }

    final class Child: Parent { let age = 32 }

    final class ParentCopyCat: Encodable, Equatable {
        let name = "Ivan"

        static func == (lhs: TestData.ParentCopyCat, rhs: TestData.ParentCopyCat) -> Bool {
            lhs.name == rhs.name
        }
    }
}
