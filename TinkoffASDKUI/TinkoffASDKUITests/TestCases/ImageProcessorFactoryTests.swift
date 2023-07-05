//
//  ImageProcessorFactoryTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 03.07.2023.
//

@testable import TinkoffASDKUI
import XCTest

final class ImageProcessorFactoryTests: XCTestCase {
    // MARK: Properties

    private var sut: ImageProcessorFactory!

    // MARK: Setup

    override func setUp() {
        super.setUp()
        sut = ImageProcessorFactory()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_thatFactoryMakesImageProcessor_whenTypeIsRound() {
        // when
        let processors = sut.makeImageProcesssors(for: .round)

        // then
        XCTAssertEqual(processors.count, 1)
        XCTAssertTrue(processors.first is RoundImageProcessor)
    }

    func test_thatFactoryMakesImageProcessor_whenTypeIsDefault() {
        // when
        let processors = sut.makeImageProcesssors(for: .default)

        // then
        XCTAssertEqual(processors.count, 0)
    }

    func test_thatFactoryMakesImageProcessor_whenTypeIsRoundAndSize() {
        // when
        let processors = sut.makeImageProcesssors(for: .roundAndSize(.zero))

        // then
        XCTAssertEqual(processors.count, 2)
        XCTAssertTrue(processors[0] is RoundImageProcessor)
        XCTAssertTrue(processors[1] is SizeImageProcessor)
    }

    func test_thatFactoryMakesImageProcessor_whenTypeIsSize() {
        // when
        let processors = sut.makeImageProcesssors(for: .size(.zero))

        // then
        XCTAssertEqual(processors.count, 1)
        XCTAssertTrue(processors.first is SizeImageProcessor)
    }
}
