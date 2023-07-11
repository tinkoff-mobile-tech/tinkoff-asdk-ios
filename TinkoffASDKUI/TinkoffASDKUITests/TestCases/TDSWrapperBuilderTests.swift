//
//  TDSWrapperBuilderTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 11.07.2023.
//

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI
import XCTest

final class TDSWrapperBuilderTests: XCTestCase {
    // MARK: Tests

    func test_thatBuildWrapper_whenEnvIsPreProd() {
        // given
        let sut = prepareSut(env: .preProd)

        // when
        let wrapper = sut.build()

        // then
        XCTAssertEqual(wrapper.checkCertificates().count, 8)
    }

    func test_thatBuildWrapper_whenEnvIsProd() {
        // given
        let sut = prepareSut(env: .prod)

        // when
        let wrapper = sut.build()

        // then
        XCTAssertEqual(wrapper.checkCertificates().count, 8)
    }

    func test_thatBuildWrapper_whenEnvIsTest() {
        // given
        let sut = prepareSut(env: .test)

        // when
        let wrapper = sut.build()

        // then
        XCTAssertEqual(wrapper.checkCertificates().count, 4)
    }

    func test_thatBuildWrapper_whenLocIsRus() {
        // given
        let sut = prepareSut(language: .ru)

        // when
        let wrapper = sut.build()

        // then
        XCTAssertEqual(wrapper.checkCertificates().count, 8)
    }

    func test_thatBuildWrapper_whenLocIsEng() {
        // given
        let sut = prepareSut(language: .en)

        // when
        let wrapper = sut.build()

        // then
        XCTAssertEqual(wrapper.checkCertificates().count, 8)
    }

    func test_thatBuildWrapper_whenLocIsNil() {
        // given
        let sut = prepareSut(language: nil)

        // when
        let wrapper = sut.build()

        // then
        XCTAssertEqual(wrapper.checkCertificates().count, 8)
    }

    // MARK: Private

    private func prepareSut(
        env: AcquiringSdkEnvironment = .preProd,
        language: AcquiringSdkLanguage? = .ru
    ) -> TDSWrapperBuilder {
        TDSWrapperBuilder(env: env, language: language)
    }
}
