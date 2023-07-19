//
//  SBPBankCellPresenterTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 25.04.2023.
//

import Foundation
import UIKit
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class SBPBankCellPresenterTests: BaseTestCase {

    var sut: SBPBankCellPresenter!

    // MARK: Mocks

    var cellMock: SBPBankCellMock!
    var cellImageLoaderMock: CellImageLoaderMock!

    // MARK: Setup

    override func setUp() {
        super.setUp()

        cellMock = SBPBankCellMock()
        setupSut(with: .blank)
    }

    override func tearDown() {
        cellMock = nil
        cellImageLoaderMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_setupCell_when_bankType_and_notLoadedImageStatus_successLoaded() {
        // given
        let image = UIImage()
        let bank = SBPBank.fakeWithUrl
        setupSut(with: .bank(bank))
        cellImageLoaderMock.loadImageCompletionClosureInput = .success(image)

        // when
        sut.cell = cellMock

        // then
        XCTAssertEqual(cellMock.setNameLabelCallsCount, 1)
        XCTAssertEqual(cellMock.setNameLabelReceivedArguments, bank.name)
        XCTAssertEqual(cellImageLoaderMock.loadImageCallsCount, 1)
        XCTAssertEqual(cellImageLoaderMock.loadImageReceivedArguments?.url, bank.logoURL)
        XCTAssertEqual(cellMock.setLogoCallsCount, 1)
        XCTAssertEqual(cellMock.setLogoReceivedArguments?.image, image)
        XCTAssertEqual(cellMock.setLogoReceivedArguments?.animated, true)
    }

    func test_setupCell_when_bankType_with_logoUrlNil_and_notLoadedImageStatus() {
        // given
        let image = UIImage()
        let bank = SBPBank.fake
        setupSut(with: .bank(bank))
        cellImageLoaderMock.loadImageCompletionClosureInput = .success(image)

        // when
        sut.cell = cellMock

        // then
        XCTAssertEqual(cellMock.setNameLabelCallsCount, 1)
        XCTAssertEqual(cellMock.setNameLabelReceivedArguments, bank.name)
        XCTAssertEqual(cellImageLoaderMock.loadImageCallsCount, 0)
        XCTAssertEqual(cellMock.setLogoCallsCount, 0)
    }

    func test_setupCell_when_bankType_and_notLoadedImageStatus_failureLoaded() {
        // given
        let error = NSError(domain: "error", code: 123456)
        let bank = SBPBank.fakeWithUrl
        setupSut(with: .bank(bank))
        cellImageLoaderMock.loadImageCompletionClosureInput = .failure(error)

        // when
        sut.cell = cellMock

        // then
        XCTAssertEqual(cellMock.setNameLabelCallsCount, 1)
        XCTAssertEqual(cellMock.setNameLabelReceivedArguments, bank.name)
        XCTAssertEqual(cellImageLoaderMock.loadImageCallsCount, 1)
        XCTAssertEqual(cellImageLoaderMock.loadImageReceivedArguments?.url, bank.logoURL)
        XCTAssertEqual(cellMock.setLogoCallsCount, 1)
        XCTAssertEqual(cellMock.setLogoReceivedArguments?.image, Asset.Sbp.sbpNoImage.image)
        XCTAssertEqual(cellMock.setLogoReceivedArguments?.animated, true)
    }

    func test_setupCell_when_bankType_and_failedPreviousTimeImageStatus_successLoaded() {
        // given
        let error = NSError(domain: "error", code: 123456)
        let image = UIImage()
        let bank = SBPBank.fakeWithUrl
        setupSut(with: .bank(bank))
        cellImageLoaderMock.loadImageCompletionClosureInput = .failure(error)

        sut.cell = cellMock

        cellMock.setNameLabelCallsCount = 0
        cellMock.setLogoCallsCount = 0
        cellMock.setLogoReceivedArguments = nil
        cellMock.setLogoReceivedInvocations = []
        cellImageLoaderMock.loadImageCallsCount = 0
        cellImageLoaderMock.loadImageCompletionClosureInput = .success(image)

        // when
        sut.cell = cellMock

        // then
        XCTAssertEqual(cellMock.setNameLabelCallsCount, 1)
        XCTAssertEqual(cellMock.setNameLabelReceivedArguments, bank.name)
        XCTAssertEqual(cellImageLoaderMock.loadImageCallsCount, 1)
        XCTAssertEqual(cellImageLoaderMock.loadImageReceivedArguments?.url, bank.logoURL)
        XCTAssertEqual(cellMock.setLogoCallsCount, 2)
        XCTAssertEqual(cellMock.setLogoReceivedInvocations[0]?.image, Asset.Sbp.sbpNoImage.image)
        XCTAssertEqual(cellMock.setLogoReceivedInvocations[1]?.image, image)
        XCTAssertEqual(cellMock.setLogoReceivedInvocations[0]?.animated, false)
        XCTAssertEqual(cellMock.setLogoReceivedInvocations[1]?.animated, true)
    }

    func test_setupCell_when_bankType_and_loadedImageStatus() {
        // given
        let image = UIImage()
        let bank = SBPBank.fakeWithUrl
        setupSut(with: .bank(bank))
        cellImageLoaderMock.loadImageCompletionClosureInput = .success(image)

        sut.cell = cellMock

        cellMock.setNameLabelCallsCount = 0
        cellMock.setLogoCallsCount = 0
        cellMock.setLogoReceivedArguments = nil
        cellMock.setLogoReceivedInvocations = []
        cellImageLoaderMock.loadImageCallsCount = 0

        // when
        sut.cell = cellMock

        // then
        XCTAssertEqual(cellMock.setNameLabelCallsCount, 1)
        XCTAssertEqual(cellMock.setNameLabelReceivedArguments, bank.name)
        XCTAssertEqual(cellImageLoaderMock.loadImageCallsCount, 0)
        XCTAssertEqual(cellMock.setLogoCallsCount, 1)
        XCTAssertEqual(cellMock.setLogoReceivedArguments?.image, image)
        XCTAssertEqual(cellMock.setLogoReceivedArguments?.animated, false)
    }

    func test_setupCell_when_bankType_and_repeatLoadingInProcess() {
        // given
        let error = NSError(domain: "error", code: 123456)
        let bank = SBPBank.fakeWithUrl
        setupSut(with: .bank(bank))

        cellImageLoaderMock.loadImageCompletionClosureInput = .failure(error)
        sut.cell = cellMock

        cellImageLoaderMock.loadImageCompletionClosureInput = nil
        sut.cell = cellMock

        cellMock.setNameLabelCallsCount = 0
        cellMock.setLogoCallsCount = 0
        cellMock.setLogoReceivedArguments = nil
        cellMock.setLogoReceivedInvocations = []
        cellImageLoaderMock.loadImageCallsCount = 0

        // when
        sut.cell = cellMock

        // then
        XCTAssertEqual(cellMock.setNameLabelCallsCount, 1)
        XCTAssertEqual(cellMock.setNameLabelReceivedArguments, bank.name)
        XCTAssertEqual(cellImageLoaderMock.loadImageCallsCount, 0)
        XCTAssertEqual(cellMock.setLogoCallsCount, 1)
        XCTAssertEqual(cellMock.setLogoReceivedArguments?.image, Asset.Sbp.sbpNoImage.image)
        XCTAssertEqual(cellMock.setLogoReceivedArguments?.animated, false)
    }

    func test_setupCell_when_bankType_and_loadingInProcess() {
        // given
        let bank = SBPBank.fakeWithUrl
        setupSut(with: .bank(bank))
        cellImageLoaderMock.loadImageCompletionClosureInput = nil
        sut.cell = cellMock

        cellMock.setNameLabelCallsCount = 0
        cellMock.setLogoCallsCount = 0
        cellImageLoaderMock.loadImageCallsCount = 0

        // when
        sut.cell = cellMock

        // then
        XCTAssertEqual(cellMock.setNameLabelCallsCount, 1)
        XCTAssertEqual(cellMock.setNameLabelReceivedArguments, bank.name)
        XCTAssertEqual(cellImageLoaderMock.loadImageCallsCount, 0)
        XCTAssertEqual(cellMock.setLogoCallsCount, 0)
    }

    func test_setupCell_when_bankButtonType() {
        // given
        let someName = "some name"
        setupSut(with: .bankButton(imageAsset: Asset.Sbp.sbpNoImage, name: someName))

        // when
        sut.cell = cellMock

        // then
        XCTAssertEqual(cellMock.setNameLabelCallsCount, 1)
        XCTAssertEqual(cellMock.setNameLabelReceivedArguments, someName)
        XCTAssertEqual(cellImageLoaderMock.loadImageCallsCount, 0)
        XCTAssertEqual(cellMock.setLogoCallsCount, 1)
        XCTAssertEqual(cellMock.setLogoReceivedArguments?.image, Asset.Sbp.sbpNoImage.image)
        XCTAssertEqual(cellMock.setLogoReceivedArguments?.animated, false)
    }

    func test_setupCell_when_skeletonType() {
        // given
        setupSut(with: .skeleton)

        // when
        sut.cell = cellMock

        // then
        XCTAssertEqual(cellMock.showSkeletonViewsCallsCount, 1)
        XCTAssertEqual(cellMock.setNameLabelCallsCount, 0)
        XCTAssertEqual(cellMock.setLogoCallsCount, 0)
    }

    func test_setupCell_when_blankType() {
        // given
        setupSut(with: .blank)

        // when
        sut.cell = cellMock

        // then
        XCTAssertEqual(cellMock.setNameLabelCallsCount, 1)
        XCTAssertEqual(cellMock.setNameLabelReceivedArguments, nil)
        XCTAssertEqual(cellMock.setLogoCallsCount, 1)
        XCTAssertEqual(cellMock.setLogoReceivedArguments?.image, nil)
        XCTAssertEqual(cellMock.setLogoReceivedArguments?.animated, false)
        XCTAssertEqual(cellMock.setCallsCount, 1)
        XCTAssertEqual(cellMock.setReceivedArguments, UITableViewCell.SelectionStyle.none)
    }
}

// MARK: - Private methods

extension SBPBankCellPresenterTests {
    private func setupSut(with type: SBPBankCellType, action: @escaping VoidBlock = {}) {
        cellImageLoaderMock = CellImageLoaderMock()
        sut = SBPBankCellPresenter(cellType: type, action: action, cellImageLoader: cellImageLoaderMock)
    }
}
