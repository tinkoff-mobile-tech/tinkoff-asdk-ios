//
//  SBPBanksPresenterTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 20.04.2023.
//

import Foundation
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class SBPBanksPresenterTests: BaseTestCase {

    var sut: SBPBanksPresenter!

    // MARK: Mocks

    var viewMock: SBPBanksViewControllerMock!
    var routerMock: SBPBanksRouterMock!
    var outputMock: SBPBanksModuleOutputMock!
    var paymentSheetOutputMock: SBPPaymentSheetPresenterOutputMock!
    var moduleCompletionMock: PaymentResultCompletion?
    var paymentServiceMock: SBPPaymentServiceMock!
    var banksServiceMock: SBPBanksServiceMock!
    var bankAppCheckerMock: SBPBankAppCheckerMock!
    var bankAppOpenerMock: SBPBankAppOpenerMock!
    var cellPresentersAssemblyMock: ISBPBankCellPresenterAssemblyMock!
    var dispatchGroupMock: DispatchGroupMock!

    // MARK: Setup

    override func setUp() {
        super.setUp()

        viewMock = SBPBanksViewControllerMock()
        routerMock = SBPBanksRouterMock()
        outputMock = SBPBanksModuleOutputMock()
        paymentSheetOutputMock = SBPPaymentSheetPresenterOutputMock()
        paymentServiceMock = SBPPaymentServiceMock()
        banksServiceMock = SBPBanksServiceMock()
        bankAppCheckerMock = SBPBankAppCheckerMock()
        bankAppOpenerMock = SBPBankAppOpenerMock()
        cellPresentersAssemblyMock = ISBPBankCellPresenterAssemblyMock()
        dispatchGroupMock = DispatchGroupMock()

        sut = SBPBanksPresenter(
            router: routerMock,
            output: outputMock,
            paymentSheetOutput: paymentSheetOutputMock,
            moduleCompletion: nil,
            paymentService: paymentServiceMock,
            banksService: banksServiceMock,
            bankAppChecker: bankAppCheckerMock,
            bankAppOpener: bankAppOpenerMock,
            cellPresentersAssembly: cellPresentersAssemblyMock,
            dispatchGroup: dispatchGroupMock
        )

        sut.view = viewMock
    }

    override func tearDown() {
        viewMock = nil
        routerMock = nil
        outputMock = nil
        paymentSheetOutputMock = nil
        moduleCompletionMock = nil
        paymentServiceMock = nil
        banksServiceMock = nil
        bankAppCheckerMock = nil
        bankAppOpenerMock = nil
        cellPresentersAssemblyMock = nil
        dispatchGroupMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_something() {
        XCTAssertTrue(true)
    }
}
