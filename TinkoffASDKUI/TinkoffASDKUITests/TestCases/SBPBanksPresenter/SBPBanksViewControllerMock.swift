//
//  SBPBanksViewControllerMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 20.04.2023.
//

@testable import TinkoffASDKUI

final class SBPBanksViewControllerMock: ISBPBanksViewController {

    // MARK: - setupNavigationWithCloseButton

    var setupNavigationWithCloseButtonCallsCount = 0

    func setupNavigationWithCloseButton() {
        setupNavigationWithCloseButtonCallsCount += 1
    }

    // MARK: - setupNavigationWithBackButton

    var setupNavigationWithBackButtonCallsCount = 0

    func setupNavigationWithBackButton() {
        setupNavigationWithBackButtonCallsCount += 1
    }

    // MARK: - showSearchBar

    var showSearchBarCallsCount = 0

    func showSearchBar() {
        showSearchBarCallsCount += 1
    }

    // MARK: - hideSearchBar

    var hideSearchBarCallsCount = 0

    func hideSearchBar() {
        hideSearchBarCallsCount += 1
    }

    // MARK: - reloadTableView

    var reloadTableViewCallsCount = 0

    func reloadTableView() {
        reloadTableViewCallsCount += 1
    }

    // MARK: - showStubView

    var showStubViewCallsCount = 0
    var showStubViewReceivedArguments: StubMode?
    var showStubViewReceivedInvocations: [StubMode] = []

    func showStubView(mode: StubMode) {
        showStubViewCallsCount += 1
        let arguments = mode
        showStubViewReceivedArguments = arguments
        showStubViewReceivedInvocations.append(arguments)
    }

    // MARK: - hideStubView

    var hideStubViewCallsCount = 0

    func hideStubView() {
        hideStubViewCallsCount += 1
    }
}
