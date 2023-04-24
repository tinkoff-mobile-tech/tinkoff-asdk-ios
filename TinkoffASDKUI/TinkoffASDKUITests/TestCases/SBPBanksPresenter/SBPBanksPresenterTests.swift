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
    var mainDispatchQueueMock: DispatchQueueMock!

    // MARK: Setup

    override func setUp() {
        super.setUp()

        configureSut()
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

    func test_viewDidLoad_when_startEmpty_and_successLoadedBanksAndQR_with_no_prefferedBanks() {
        // given
        let skeletonsCount = 7
        let loadedBanks = [SBPBank](repeating: .any, count: 3)
        let emptyCellsCount = max(skeletonsCount - loadedBanks.count, 0)
        let skeletonsAndBanksCount = skeletonsCount + loadedBanks.count
        let cellPresentersAssemblyCallsCount = skeletonsAndBanksCount + emptyCellsCount

        cellPresentersAssemblyMock.buildReturnValue = anyCellPresenter
        cellPresentersAssemblyMock.buildWithActionReturnValue = anyCellPresenter
        paymentServiceMock.loadPaymentQrCompletionClosureInput = .success(.any)
        banksServiceMock.loadBanksCompletionClosureInput = .success(loadedBanks)
        dispatchGroupMock.notifyWorkShouldCalls = true
        bankAppCheckerMock.bankAppsPreferredByMerchantReturnValue = []

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.hideSearchBarCallsCount, 1)
        XCTAssertEqual(viewMock.reloadTableViewCallsCount, 2)
        XCTAssertEqual(dispatchGroupMock.enterCallsCount, 2)
        XCTAssertEqual(dispatchGroupMock.leaveCallsCount, 2)
        XCTAssertEqual(dispatchGroupMock.notifyCallsCount, 1)
        XCTAssertEqual(dispatchGroupMock.notifyReceivedArguments?.queue, .main)
        XCTAssertEqual(paymentServiceMock.loadPaymentQrCallsCount, 1)
        XCTAssertEqual(banksServiceMock.loadBanksCallsCount, 1)
        XCTAssertEqual(bankAppCheckerMock.bankAppsPreferredByMerchantCallsCount, 1)
        XCTAssertEqual(bankAppCheckerMock.bankAppsPreferredByMerchantReceivedArguments, loadedBanks)
        XCTAssertEqual(viewMock.showSearchBarCallsCount, 1)
        XCTAssertEqual(outputMock.didLoadedCallsCount, 1)
        XCTAssertEqual(outputMock.didLoadedReceivedArguments, loadedBanks)
        XCTAssertEqual(viewMock.setupNavigationWithCloseButtonCallsCount, 1)
        XCTAssertEqual(cellPresentersAssemblyMock.buildCommonCallsCount, cellPresentersAssemblyCallsCount)

        cellPresentersAssemblyMock.buildCommonInvocations.enumerated().forEach { index, cellType in
            switch index {
            case 0 ..< skeletonsCount: XCTAssertEqual(cellType, .skeleton)
            case skeletonsCount ..< skeletonsAndBanksCount: XCTAssertEqual(cellType, .bank(.any))
            case skeletonsAndBanksCount ..< cellPresentersAssemblyCallsCount: XCTAssertEqual(cellType, .blank)
                fallthrough
            default: break
            }
        }
    }

    func test_viewDidLoad_when_startEmpty_and_successLoadedBanksAndQR_with_prefferedBanks() {
        // given
        let otherImage = Asset.Sbp.sbpLogo
        let otherName = Loc.Acquiring.SBPBanks.anotherBank
        let otherButtonType: SBPBankCellType = .bankButton(imageAsset: otherImage, name: otherName)
        let skeletonsCount = 7
        let otherBankCount = 1
        let skeletonsWithOtherBankCount = skeletonsCount + otherBankCount
        let loadedBanks = [SBPBank](repeating: .any, count: 6)
        let preferredBanks = [SBPBank](repeating: .any, count: 4)
        let emptyCellsCount = max(skeletonsCount - preferredBanks.count - otherBankCount, 0)
        let skeletonsAndBanksWithOtherCount = skeletonsWithOtherBankCount + preferredBanks.count
        let cellPresentersAssemblyCallsCount = skeletonsAndBanksWithOtherCount + emptyCellsCount

        cellPresentersAssemblyMock.buildReturnValue = anyCellPresenter
        cellPresentersAssemblyMock.buildWithActionReturnValue = anyCellPresenter
        paymentServiceMock.loadPaymentQrCompletionClosureInput = .success(.any)
        banksServiceMock.loadBanksCompletionClosureInput = .success(loadedBanks)
        dispatchGroupMock.notifyWorkShouldCalls = true
        bankAppCheckerMock.bankAppsPreferredByMerchantReturnValue = preferredBanks

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.hideSearchBarCallsCount, 1)
        XCTAssertEqual(viewMock.reloadTableViewCallsCount, 2)
        XCTAssertEqual(dispatchGroupMock.enterCallsCount, 2)
        XCTAssertEqual(dispatchGroupMock.leaveCallsCount, 2)
        XCTAssertEqual(dispatchGroupMock.notifyCallsCount, 1)
        XCTAssertEqual(dispatchGroupMock.notifyReceivedArguments?.queue, .main)
        XCTAssertEqual(paymentServiceMock.loadPaymentQrCallsCount, 1)
        XCTAssertEqual(banksServiceMock.loadBanksCallsCount, 1)
        XCTAssertEqual(bankAppCheckerMock.bankAppsPreferredByMerchantCallsCount, 1)
        XCTAssertEqual(bankAppCheckerMock.bankAppsPreferredByMerchantReceivedArguments, loadedBanks)
        XCTAssertEqual(viewMock.showSearchBarCallsCount, 0)
        XCTAssertEqual(outputMock.didLoadedCallsCount, 1)
        XCTAssertEqual(outputMock.didLoadedReceivedArguments, loadedBanks)
        XCTAssertEqual(viewMock.setupNavigationWithCloseButtonCallsCount, 1)
        XCTAssertEqual(cellPresentersAssemblyMock.buildCommonCallsCount, cellPresentersAssemblyCallsCount)

        cellPresentersAssemblyMock.buildCommonInvocations.enumerated().forEach { index, cellType in
            switch index {
            case 0 ..< skeletonsCount:
                XCTAssertEqual(cellType, .skeleton)
            case skeletonsCount ..< skeletonsWithOtherBankCount:
                XCTAssertEqual(cellType, otherButtonType)
            case skeletonsWithOtherBankCount ..< skeletonsAndBanksWithOtherCount:
                XCTAssertEqual(cellType, .bank(.any))
            case skeletonsAndBanksWithOtherCount ..< cellPresentersAssemblyCallsCount: XCTAssertEqual(cellType, .blank)
                fallthrough
            default: break
            }
        }
    }

    func test_viewDidLoad_when_startEmpty_and_failureLoadedBanksAndQR_with_internetError() {
        // given
        let skeletonsCount = 7
        let error = NSError(domain: "error", code: NSURLErrorNotConnectedToInternet)

        cellPresentersAssemblyMock.buildReturnValue = anyCellPresenter
        paymentServiceMock.loadPaymentQrCompletionClosureInput = .failure(error)
        banksServiceMock.loadBanksCompletionClosureInput = .failure(error)
        dispatchGroupMock.notifyWorkShouldCalls = true

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.hideSearchBarCallsCount, 1)
        XCTAssertEqual(viewMock.reloadTableViewCallsCount, 2)
        XCTAssertEqual(dispatchGroupMock.enterCallsCount, 2)
        XCTAssertEqual(dispatchGroupMock.leaveCallsCount, 2)
        XCTAssertEqual(dispatchGroupMock.notifyCallsCount, 1)
        XCTAssertEqual(dispatchGroupMock.notifyReceivedArguments?.queue, .main)
        XCTAssertEqual(paymentServiceMock.loadPaymentQrCallsCount, 1)
        XCTAssertEqual(banksServiceMock.loadBanksCallsCount, 1)
        XCTAssertEqual(viewMock.setupNavigationWithCloseButtonCallsCount, 1)
        XCTAssertEqual(viewMock.showStubViewCallsCount, 1)
        XCTAssertEqual(viewMock.showStubViewReceivedArguments, .noNetwork())
        XCTAssertEqual(cellPresentersAssemblyMock.buildCommonCallsCount, skeletonsCount)

        cellPresentersAssemblyMock.buildCommonInvocations.forEach { XCTAssertEqual($0, .skeleton) }
    }

    func test_viewDidLoad_when_startEmpty_and_failure_because_no_needed_requests() {
        // given
        let skeletonsCount = 7

        cellPresentersAssemblyMock.buildReturnValue = anyCellPresenter
        dispatchGroupMock.notifyWorkShouldCalls = true

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.hideSearchBarCallsCount, 1)
        XCTAssertEqual(viewMock.reloadTableViewCallsCount, 2)
        XCTAssertEqual(dispatchGroupMock.enterCallsCount, 2)
        XCTAssertEqual(dispatchGroupMock.leaveCallsCount, 0)
        XCTAssertEqual(dispatchGroupMock.notifyCallsCount, 1)
        XCTAssertEqual(dispatchGroupMock.notifyReceivedArguments?.queue, .main)
        XCTAssertEqual(paymentServiceMock.loadPaymentQrCallsCount, 1)
        XCTAssertEqual(banksServiceMock.loadBanksCallsCount, 1)
        XCTAssertEqual(viewMock.setupNavigationWithCloseButtonCallsCount, 1)
        XCTAssertEqual(viewMock.showStubViewCallsCount, 1)
        XCTAssertEqual(viewMock.showStubViewReceivedArguments, .serverError())
        XCTAssertEqual(cellPresentersAssemblyMock.buildCommonCallsCount, skeletonsCount)

        cellPresentersAssemblyMock.buildCommonInvocations.forEach { XCTAssertEqual($0, .skeleton) }
    }

    func test_viewDidLoad_when_startWithBanks_and_failureLoadedQR_with_serverError() {
        // given
        let skeletonsCount = 7
        let loadedBanks = [SBPBank](repeating: .any, count: 3)

        let error = NSError(domain: "error", code: 1234)

        cellPresentersAssemblyMock.buildReturnValue = anyCellPresenter
        paymentServiceMock.loadPaymentQrCompletionClosureInput = .failure(error)
        mainDispatchQueueMock.asyncWorkShouldCalls = true

        sut.set(banks: loadedBanks)

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.hideSearchBarCallsCount, 1)
        XCTAssertEqual(viewMock.reloadTableViewCallsCount, 2)
        XCTAssertEqual(paymentServiceMock.loadPaymentQrCallsCount, 1)
        XCTAssertEqual(banksServiceMock.loadBanksCallsCount, 0)
        XCTAssertEqual(mainDispatchQueueMock.asyncCallsCount, 1)
        XCTAssertEqual(viewMock.setupNavigationWithCloseButtonCallsCount, 1)
        XCTAssertEqual(viewMock.showStubViewCallsCount, 1)
        XCTAssertEqual(viewMock.showStubViewReceivedArguments, .serverError())
        XCTAssertEqual(cellPresentersAssemblyMock.buildCommonCallsCount, skeletonsCount)

        cellPresentersAssemblyMock.buildCommonInvocations.forEach { XCTAssertEqual($0, .skeleton) }
    }

    func test_viewDidLoad_when_startWithBanks_and_failureLoadedQR_with_internetError() {
        // given
        let skeletonsCount = 7
        let loadedBanks = [SBPBank](repeating: .any, count: 3)

        let error = NSError(domain: "error", code: NSURLErrorNotConnectedToInternet)

        cellPresentersAssemblyMock.buildReturnValue = anyCellPresenter
        paymentServiceMock.loadPaymentQrCompletionClosureInput = .failure(error)
        mainDispatchQueueMock.asyncWorkShouldCalls = true

        sut.set(banks: loadedBanks)

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.hideSearchBarCallsCount, 1)
        XCTAssertEqual(viewMock.reloadTableViewCallsCount, 2)
        XCTAssertEqual(paymentServiceMock.loadPaymentQrCallsCount, 1)
        XCTAssertEqual(banksServiceMock.loadBanksCallsCount, 0)
        XCTAssertEqual(mainDispatchQueueMock.asyncCallsCount, 1)
        XCTAssertEqual(viewMock.setupNavigationWithCloseButtonCallsCount, 1)
        XCTAssertEqual(viewMock.showStubViewCallsCount, 1)
        XCTAssertEqual(viewMock.showStubViewReceivedArguments, .noNetwork())
        XCTAssertEqual(cellPresentersAssemblyMock.buildCommonCallsCount, skeletonsCount)

        cellPresentersAssemblyMock.buildCommonInvocations.forEach { XCTAssertEqual($0, .skeleton) }
    }

    func test_viewDidLoad_when_startWithBanks_and_successLoadedQR_with_no_prefferedBanks() {
        // given
        let skeletonsCount = 7
        let loadedBanks = [SBPBank](repeating: .any, count: 3)
        let emptyCellsCount = max(skeletonsCount - loadedBanks.count, 0)
        let skeletonsAndBanksCount = skeletonsCount + loadedBanks.count
        let cellPresentersAssemblyCallsCount = skeletonsAndBanksCount + emptyCellsCount

        cellPresentersAssemblyMock.buildReturnValue = anyCellPresenter
        cellPresentersAssemblyMock.buildWithActionReturnValue = anyCellPresenter
        paymentServiceMock.loadPaymentQrCompletionClosureInput = .success(.any)
        banksServiceMock.loadBanksCompletionClosureInput = .success(loadedBanks)
        mainDispatchQueueMock.asyncWorkShouldCalls = true
        bankAppCheckerMock.bankAppsPreferredByMerchantReturnValue = []

        sut.set(banks: loadedBanks)

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.hideSearchBarCallsCount, 1)
        XCTAssertEqual(viewMock.reloadTableViewCallsCount, 2)
        XCTAssertEqual(paymentServiceMock.loadPaymentQrCallsCount, 1)
        XCTAssertEqual(banksServiceMock.loadBanksCallsCount, 0)
        XCTAssertEqual(mainDispatchQueueMock.asyncCallsCount, 1)
        XCTAssertEqual(bankAppCheckerMock.bankAppsPreferredByMerchantCallsCount, 1)
        XCTAssertEqual(bankAppCheckerMock.bankAppsPreferredByMerchantReceivedArguments, loadedBanks)
        XCTAssertEqual(viewMock.showSearchBarCallsCount, 1)
        XCTAssertEqual(outputMock.didLoadedCallsCount, 0)
        XCTAssertEqual(viewMock.setupNavigationWithCloseButtonCallsCount, 1)
        XCTAssertEqual(cellPresentersAssemblyMock.buildCommonCallsCount, cellPresentersAssemblyCallsCount)

        cellPresentersAssemblyMock.buildCommonInvocations.enumerated().forEach { index, cellType in
            switch index {
            case 0 ..< skeletonsCount: XCTAssertEqual(cellType, .skeleton)
            case skeletonsCount ..< skeletonsAndBanksCount: XCTAssertEqual(cellType, .bank(.any))
            case skeletonsAndBanksCount ..< cellPresentersAssemblyCallsCount: XCTAssertEqual(cellType, .blank)
                fallthrough
            default: break
            }
        }
    }

    func test_viewDidLoad_when_startWithFullData_with_notNilQrPayload() {
        // given
        let loadedBanks = [SBPBank](repeating: .any, count: 5)
        cellPresentersAssemblyMock.buildWithActionReturnValue = anyCellPresenter

        sut.set(qrPayload: .any, banks: loadedBanks)

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.reloadTableViewCallsCount, 1)
        XCTAssertEqual(viewMock.setupNavigationWithBackButtonCallsCount, 1)
        XCTAssertEqual(cellPresentersAssemblyMock.buildCommonCallsCount, loadedBanks.count)

        cellPresentersAssemblyMock.buildCommonInvocations.forEach {
            XCTAssertEqual($0, .bank(.any))
        }
    }

    func test_viewDidLoad_when_startWithFullData_with_nilQrPayload() {
        // given
        let loadedBanks = [SBPBank](repeating: .any, count: 5)
        cellPresentersAssemblyMock.buildWithActionReturnValue = anyCellPresenter

        sut.set(qrPayload: nil, banks: loadedBanks)

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.reloadTableViewCallsCount, 1)
        XCTAssertEqual(viewMock.setupNavigationWithBackButtonCallsCount, 1)
        XCTAssertEqual(cellPresentersAssemblyMock.buildCommonCallsCount, 0)
    }

    func test_otherBankCellPresenter_action() throws {
        // given
        let otherImage = Asset.Sbp.sbpLogo
        let otherName = Loc.Acquiring.SBPBanks.anotherBank
        let otherButtonType: SBPBankCellType = .bankButton(imageAsset: otherImage, name: otherName)
        let loadedBanks = Array(1 ... 10).map { SBPBank.some($0) }
        let preferredBanks = Array(1 ... 4).map { SBPBank.some($0) }
        let notPreferredBanks = Array(5 ... 10).map { SBPBank.some($0) }

        cellPresentersAssemblyMock.buildReturnValue = anyCellPresenter
        cellPresentersAssemblyMock.buildWithActionReturnValue = anyCellPresenter
        paymentServiceMock.loadPaymentQrCompletionClosureInput = .success(.any)
        banksServiceMock.loadBanksCompletionClosureInput = .success(loadedBanks)
        dispatchGroupMock.notifyWorkShouldCalls = true
        bankAppCheckerMock.bankAppsPreferredByMerchantReturnValue = preferredBanks

        sut.viewDidLoad()
        let otherBankInvocationOptional = cellPresentersAssemblyMock.buildWithActionReceivedInvocations
            .filter { $0.cellType == otherButtonType }.first
        let otherBankInvocation = try XCTUnwrap(otherBankInvocationOptional)

        // when
        otherBankInvocation.action()

        // then
        XCTAssertEqual(routerMock.showCallsCount, 1)
        XCTAssertEqual(routerMock.showReceivedArguments?.banks, notPreferredBanks)
        XCTAssertEqual(routerMock.showReceivedArguments?.qrPayload, .any)
    }

    func test_otherBankCellPresenter_action_when_presenterNil() throws {
        // given
        let otherImage = Asset.Sbp.sbpLogo
        let otherName = Loc.Acquiring.SBPBanks.anotherBank
        let otherButtonType: SBPBankCellType = .bankButton(imageAsset: otherImage, name: otherName)
        let loadedBanks = Array(1 ... 10).map { SBPBank.some($0) }
        let preferredBanks = Array(1 ... 4).map { SBPBank.some($0) }

        cellPresentersAssemblyMock.buildReturnValue = anyCellPresenter
        cellPresentersAssemblyMock.buildWithActionReturnValue = anyCellPresenter
        paymentServiceMock.loadPaymentQrCompletionClosureInput = .success(.any)
        banksServiceMock.loadBanksCompletionClosureInput = .success(loadedBanks)
        dispatchGroupMock.notifyWorkShouldCalls = true
        bankAppCheckerMock.bankAppsPreferredByMerchantReturnValue = preferredBanks

        sut.viewDidLoad()
        let otherBankInvocationOptional = cellPresentersAssemblyMock.buildWithActionReceivedInvocations
            .filter { $0.cellType == otherButtonType }.first
        let otherBankInvocation = try XCTUnwrap(otherBankInvocationOptional)
        sut = nil

        // when
        otherBankInvocation.action()

        // then
        XCTAssertEqual(routerMock.showCallsCount, 0)
    }

    func test_anyBankCellPresenter_action_with_successOpen() throws {
        // given
        let qrPayload = GetQRPayload.any
        let neededURL = URL(string: qrPayload.qrCodeData)
        let loadedBanks = [SBPBank](repeating: .any, count: 5)
        cellPresentersAssemblyMock.buildWithActionReturnValue = anyCellPresenter
        bankAppOpenerMock.openBankAppCompletionClosureInput = true

        sut.set(qrPayload: .any, banks: loadedBanks)
        sut.viewDidLoad()

        let anyBankInvocationOptional = cellPresentersAssemblyMock.buildWithActionReceivedInvocations.first
        let anyBankInvocation = try XCTUnwrap(anyBankInvocationOptional)

        // when
        anyBankInvocation.action()

        // then
        XCTAssertEqual(bankAppOpenerMock.openBankAppCallsCount, 1)
        XCTAssertEqual(bankAppOpenerMock.openBankAppReceivedArguments?.url, neededURL)
        XCTAssertEqual(bankAppOpenerMock.openBankAppReceivedArguments?.bank, loadedBanks.first)
        XCTAssertEqual(routerMock.showPaymentSheetCallsCount, 1)
        XCTAssertEqual(routerMock.showPaymentSheetReceivedArguments?.paymentId, qrPayload.paymentId)
    }

    func test_anyBankCellPresenter_action_with_failureOpen() throws {
        // given
        let qrPayload = GetQRPayload.any
        let neededURL = URL(string: qrPayload.qrCodeData)
        let loadedBanks = [SBPBank](repeating: .any, count: 5)
        cellPresentersAssemblyMock.buildWithActionReturnValue = anyCellPresenter
        bankAppOpenerMock.openBankAppCompletionClosureInput = false

        sut.set(qrPayload: .any, banks: loadedBanks)
        sut.viewDidLoad()

        let anyBankInvocationOptional = cellPresentersAssemblyMock.buildWithActionReceivedInvocations.first
        let anyBankInvocation = try XCTUnwrap(anyBankInvocationOptional)

        // when
        anyBankInvocation.action()

        // then
        XCTAssertEqual(bankAppOpenerMock.openBankAppCallsCount, 1)
        XCTAssertEqual(bankAppOpenerMock.openBankAppReceivedArguments?.url, neededURL)
        XCTAssertEqual(bankAppOpenerMock.openBankAppReceivedArguments?.bank, loadedBanks.first)
        XCTAssertEqual(routerMock.showPaymentSheetCallsCount, 0)
        XCTAssertEqual(routerMock.showDidNotFindBankAppAlertCallsCount, 1)
    }

    func test_noNetworkStub_action_when_startEmpty() throws {
        // given
        let skeletonsCount = 7
        let error = NSError(domain: "error", code: NSURLErrorNotConnectedToInternet)

        cellPresentersAssemblyMock.buildReturnValue = anyCellPresenter
        paymentServiceMock.loadPaymentQrCompletionClosureInput = .failure(error)
        banksServiceMock.loadBanksCompletionClosureInput = .failure(error)
        dispatchGroupMock.notifyWorkShouldCalls = true

        sut.viewDidLoad()
        let stub = try XCTUnwrap(viewMock.showStubViewReceivedArguments)

        cellPresentersAssemblyMock.buildCommonCallsCount = 0
        viewMock.reloadTableViewCallsCount = 0
        paymentServiceMock.loadPaymentQrCallsCount = 0
        banksServiceMock.loadBanksCallsCount = 0
        dispatchGroupMock.enterCallsCount = 0
        dispatchGroupMock.leaveCallsCount = 0
        dispatchGroupMock.notifyCallsCount = 0
        dispatchGroupMock.notifyReceivedArguments = nil
        dispatchGroupMock.notifyWorkShouldCalls = false

        // when
        switch stub {
        case let .noNetwork(action):
            action()
            fallthrough
        default: break
        }

        // then
        XCTAssertEqual(stub, .noNetwork())
        XCTAssertEqual(viewMock.hideStubViewCallsCount, 1)
        XCTAssertEqual(viewMock.reloadTableViewCallsCount, 1)
        XCTAssertEqual(paymentServiceMock.loadPaymentQrCallsCount, 1)
        XCTAssertEqual(banksServiceMock.loadBanksCallsCount, 1)
        XCTAssertEqual(dispatchGroupMock.enterCallsCount, 2)
        XCTAssertEqual(dispatchGroupMock.leaveCallsCount, 2)
        XCTAssertEqual(dispatchGroupMock.notifyCallsCount, 1)
        XCTAssertEqual(dispatchGroupMock.notifyReceivedArguments?.queue, .main)
        XCTAssertEqual(cellPresentersAssemblyMock.buildCommonCallsCount, skeletonsCount)

        cellPresentersAssemblyMock.buildCommonInvocations.forEach { XCTAssertEqual($0, .skeleton) }
    }

    func test_noNetworkStub_action_when_startWithBanks() throws {
        // given
        let skeletonsCount = 7
        let error = NSError(domain: "error", code: NSURLErrorNotConnectedToInternet)
        let loadedBanks = [SBPBank](repeating: .any, count: 3)

        cellPresentersAssemblyMock.buildReturnValue = anyCellPresenter
        paymentServiceMock.loadPaymentQrCompletionClosureInput = .failure(error)
        banksServiceMock.loadBanksCompletionClosureInput = .failure(error)
        mainDispatchQueueMock.asyncWorkShouldCalls = true

        sut.set(banks: loadedBanks)
        sut.viewDidLoad()
        let stub = try XCTUnwrap(viewMock.showStubViewReceivedArguments)

        cellPresentersAssemblyMock.buildCommonCallsCount = 0
        viewMock.reloadTableViewCallsCount = 0
        paymentServiceMock.loadPaymentQrCallsCount = 0
        mainDispatchQueueMock.asyncWorkShouldCalls = false

        // when
        switch stub {
        case let .noNetwork(action):
            action()
            fallthrough
        default: break
        }

        // then
        XCTAssertEqual(stub, .noNetwork())
        XCTAssertEqual(viewMock.hideStubViewCallsCount, 1)
        XCTAssertEqual(viewMock.reloadTableViewCallsCount, 1)
        XCTAssertEqual(paymentServiceMock.loadPaymentQrCallsCount, 1)
        XCTAssertEqual(banksServiceMock.loadBanksCallsCount, 0)
        XCTAssertEqual(cellPresentersAssemblyMock.buildCommonCallsCount, skeletonsCount)

        cellPresentersAssemblyMock.buildCommonInvocations.forEach { XCTAssertEqual($0, .skeleton) }
    }

    func test_noNetworkStub_action_when_presenterNil() throws {
        // given
        let error = NSError(domain: "error", code: NSURLErrorNotConnectedToInternet)

        cellPresentersAssemblyMock.buildReturnValue = anyCellPresenter
        paymentServiceMock.loadPaymentQrCompletionClosureInput = .failure(error)
        banksServiceMock.loadBanksCompletionClosureInput = .failure(error)
        dispatchGroupMock.notifyWorkShouldCalls = true

        sut.viewDidLoad()
        let stub = try XCTUnwrap(viewMock.showStubViewReceivedArguments)
        sut = nil

        cellPresentersAssemblyMock.buildCommonCallsCount = 0
        viewMock.reloadTableViewCallsCount = 0
        paymentServiceMock.loadPaymentQrCallsCount = 0
        banksServiceMock.loadBanksCallsCount = 0

        // when
        switch stub {
        case let .noNetwork(action):
            action()
            fallthrough
        default: break
        }

        // then
        XCTAssertEqual(stub, .noNetwork())
        XCTAssertEqual(viewMock.hideStubViewCallsCount, 0)
        XCTAssertEqual(viewMock.reloadTableViewCallsCount, 0)
        XCTAssertEqual(paymentServiceMock.loadPaymentQrCallsCount, 0)
        XCTAssertEqual(banksServiceMock.loadBanksCallsCount, 0)
        XCTAssertEqual(cellPresentersAssemblyMock.buildCommonCallsCount, 0)
    }

    func test_serverErrorStub_action() throws {
        // given
        var isModuleCompletionCalled = false
        var moduleCompletionResult: PaymentResult?
        moduleCompletionMock = { result in
            isModuleCompletionCalled = true
            moduleCompletionResult = result
        }

        configureSut()

        let error = NSError(domain: "error", code: 123456)

        cellPresentersAssemblyMock.buildReturnValue = anyCellPresenter
        paymentServiceMock.loadPaymentQrCompletionClosureInput = .failure(error)
        banksServiceMock.loadBanksCompletionClosureInput = .failure(error)
        dispatchGroupMock.notifyWorkShouldCalls = true
        routerMock.closeScreenCompletionShouldCalls = true

        sut.viewDidLoad()
        let stub = try XCTUnwrap(viewMock.showStubViewReceivedArguments)

        // when
        switch stub {
        case let .serverError(action):
            action()
            fallthrough
        default: break
        }

        // then
        XCTAssertEqual(routerMock.closeScreenCallsCount, 1)
        XCTAssertEqual(paymentSheetOutputMock.sbpPaymentSheetCallsCount, 1)
        XCTAssertEqual(paymentSheetOutputMock.sbpPaymentSheetReceivedArguments, .failed(error))
        XCTAssertEqual(moduleCompletionResult, .failed(error))
        XCTAssertTrue(isModuleCompletionCalled)
    }

    func test_closeButtonPressed() {
        // given
        var isModuleCompletionCalled = false
        var moduleCompletionResult: PaymentResult?
        moduleCompletionMock = { result in
            isModuleCompletionCalled = true
            moduleCompletionResult = result
        }

        configureSut()
        routerMock.closeScreenCompletionShouldCalls = true

        // when
        sut.closeButtonPressed()

        // then
        XCTAssertEqual(routerMock.closeScreenCallsCount, 1)
        XCTAssertEqual(paymentSheetOutputMock.sbpPaymentSheetCallsCount, 1)
        XCTAssertEqual(paymentSheetOutputMock.sbpPaymentSheetReceivedArguments, .cancelled())
        XCTAssertEqual(moduleCompletionResult, .cancelled())
        XCTAssertTrue(isModuleCompletionCalled)
    }

    func test_controllerDidDismissManually() {
        // given
        var isModuleCompletionCalled = false
        var moduleCompletionResult: PaymentResult?
        moduleCompletionMock = { result in
            isModuleCompletionCalled = true
            moduleCompletionResult = result
        }

        configureSut()

        // when
        sut.controllerDidDismissManually()

        // then
        XCTAssertEqual(paymentSheetOutputMock.sbpPaymentSheetCallsCount, 1)
        XCTAssertEqual(paymentSheetOutputMock.sbpPaymentSheetReceivedArguments, .cancelled())
        XCTAssertEqual(moduleCompletionResult, .cancelled())
        XCTAssertTrue(isModuleCompletionCalled)
    }

    func test_prefetchForRows() {
        // given
        let loadedBanks = [SBPBank](repeating: .any, count: 5)
        let cellPresenterMock = SBPBankCellPresenterMock()
        cellPresentersAssemblyMock.buildReturnValue = cellPresenterMock
        cellPresentersAssemblyMock.buildWithActionReturnValue = cellPresenterMock

        sut.set(qrPayload: .any, banks: loadedBanks)
        sut.viewDidLoad()

        // when
        sut.prefetch(for: [1])

        // then
        XCTAssertEqual(cellPresenterMock.startLoadingCellImageIfNeededCallsCount, 1)
    }

    func test_numberOfRows() {
        // given
        let loadedBanks = [SBPBank](repeating: .any, count: 7)
        cellPresentersAssemblyMock.buildReturnValue = anyCellPresenter
        cellPresentersAssemblyMock.buildWithActionReturnValue = anyCellPresenter

        sut.set(qrPayload: .any, banks: loadedBanks)
        sut.viewDidLoad()

        // when
        let numberOfRows = sut.numberOfRows()

        // then
        XCTAssertEqual(numberOfRows, loadedBanks.count)
    }

    func test_searchTextDidChange_with_notEmptyText() {
        // given
        let loadedBanks = [SBPBank](repeating: .any, count: 5)
        cellPresentersAssemblyMock.buildReturnValue = anyCellPresenter
        cellPresentersAssemblyMock.buildWithActionReturnValue = anyCellPresenter
        mainDispatchQueueMock.asyncDedupedWorkShouldCalls = true

        sut.set(qrPayload: .any, banks: loadedBanks)
        sut.viewDidLoad()

        viewMock.reloadTableViewCallsCount = 0

        // when
        sut.searchTextDidChange(to: "1")

        // then
        XCTAssertEqual(mainDispatchQueueMock.asyncDedupedCallsCount, 1)
        XCTAssertEqual(mainDispatchQueueMock.asyncDedupedReceivedArguments?.delay, 0.3)
        XCTAssertEqual(viewMock.reloadTableViewCallsCount, 1)
    }

    func test_searchTextDidChange_when_textEmpty() {
        // given
        let loadedBanks = [SBPBank](repeating: .any, count: 5)
        cellPresentersAssemblyMock.buildReturnValue = anyCellPresenter
        cellPresentersAssemblyMock.buildWithActionReturnValue = anyCellPresenter
        mainDispatchQueueMock.asyncDedupedWorkShouldCalls = true

        sut.set(qrPayload: .any, banks: loadedBanks)
        sut.viewDidLoad()

        sut.searchTextDidChange(to: "1")
        mainDispatchQueueMock.asyncDedupedCallsCount = 0
        viewMock.reloadTableViewCallsCount = 0

        // when
        sut.searchTextDidChange(to: "")

        // then
        XCTAssertEqual(mainDispatchQueueMock.asyncDedupedCallsCount, 1)
        XCTAssertEqual(mainDispatchQueueMock.asyncDedupedReceivedArguments?.delay, 0.3)
        XCTAssertEqual(viewMock.reloadTableViewCallsCount, 1)
    }

    func test_searchTextDidChange_when_textEqualLastText() {
        // given
        let loadedBanks = [SBPBank](repeating: .any, count: 5)
        cellPresentersAssemblyMock.buildReturnValue = anyCellPresenter
        cellPresentersAssemblyMock.buildWithActionReturnValue = anyCellPresenter
        mainDispatchQueueMock.asyncDedupedWorkShouldCalls = true

        sut.set(qrPayload: .any, banks: loadedBanks)
        sut.viewDidLoad()

        viewMock.reloadTableViewCallsCount = 0

        // when
        sut.searchTextDidChange(to: "")

        // then
        XCTAssertEqual(mainDispatchQueueMock.asyncDedupedCallsCount, 0)
        XCTAssertEqual(viewMock.reloadTableViewCallsCount, 0)
    }

    func test_didSelectRowAtIndex() {
        // given
        let loadedBanks = [SBPBank](repeating: .any, count: 5)
        let cellPresenterMock = SBPBankCellPresenterMock()

        var isCellPresenterActionCalled = false
        cellPresenterMock.action = {
            isCellPresenterActionCalled = true
        }

        cellPresentersAssemblyMock.buildReturnValue = cellPresenterMock
        cellPresentersAssemblyMock.buildWithActionReturnValue = cellPresenterMock

        sut.set(qrPayload: .any, banks: loadedBanks)
        sut.viewDidLoad()

        // when
        sut.didSelectRow(at: 0)

        // then
        XCTAssertTrue(isCellPresenterActionCalled)
    }

    func test_sbpPaymentSheetCompletedWithResult() {
        // given
        var isModuleCompletionCalled = false
        var moduleCompletionResult: PaymentResult?
        moduleCompletionMock = { result in
            isModuleCompletionCalled = true
            moduleCompletionResult = result
        }

        configureSut()
        routerMock.closeScreenCompletionShouldCalls = true

        // when
        sut.sbpPaymentSheet(completedWith: .cancelled())

        // then
        XCTAssertEqual(routerMock.closeScreenCallsCount, 1)
        XCTAssertEqual(paymentSheetOutputMock.sbpPaymentSheetCallsCount, 1)
        XCTAssertEqual(paymentSheetOutputMock.sbpPaymentSheetReceivedArguments, .cancelled())
        XCTAssertEqual(moduleCompletionResult, .cancelled())
        XCTAssertTrue(isModuleCompletionCalled)
    }
}

// MARK: - Private methods

extension SBPBanksPresenterTests {
    private func configureSut() {
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
        mainDispatchQueueMock = DispatchQueueMock()

        sut = SBPBanksPresenter(
            router: routerMock,
            output: outputMock,
            paymentSheetOutput: paymentSheetOutputMock,
            moduleCompletion: moduleCompletionMock,
            paymentService: paymentServiceMock,
            banksService: banksServiceMock,
            bankAppChecker: bankAppCheckerMock,
            bankAppOpener: bankAppOpenerMock,
            cellPresentersAssembly: cellPresentersAssemblyMock,
            dispatchGroup: dispatchGroupMock,
            mainDispatchQueue: mainDispatchQueueMock
        )

        sut.view = viewMock
    }

    var cellImageLoaderMock: CellImageLoaderMock {
        CellImageLoaderMock()
    }

    var anyCellPresenter: ISBPBankCellPresenter {
        SBPBankCellPresenter(cellType: .blank, action: {}, cellImageLoader: cellImageLoaderMock)
    }
}

// MARK: - Helpers

extension GetQRPayload {
    static let any = GetQRPayload(qrCodeData: "https://www.google.com", orderId: "1234", paymentId: "4567")
}

extension SBPBank {
    static var any: SBPBank {
        SBPBank(name: "name", logoURL: nil, schema: "scheme")
    }

    static func some(_ uniqValue: Int) -> SBPBank {
        SBPBank(name: "name \(uniqValue)", logoURL: nil, schema: "scheme \(uniqValue)")
    }
}
