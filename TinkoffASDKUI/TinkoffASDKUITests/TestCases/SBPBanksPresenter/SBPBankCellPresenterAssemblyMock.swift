//
//  SBPBankCellPresenterAssemblyMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 20.04.2023.
//

@testable import TinkoffASDKUI

final class SBPBankCellPresenterAssemblyMock: ISBPBankCellPresenterAssembly {

    // MARK: - Common

    var buildCommonCallsCount = 0
    var buildCommonInvocations: [BuildCellTypeArguments?] = []

    // MARK: - buildCellType

    typealias BuildCellTypeArguments = SBPBankCellType

    var buildCellTypeCallsCount = 0
    var buildCellTypeReceivedArguments: BuildCellTypeArguments?
    var buildCellTypeReceivedInvocations: [BuildCellTypeArguments?] = []
    var buildCellTypeReturnValue: ISBPBankCellPresenter!

    func build(cellType: SBPBankCellType) -> ISBPBankCellPresenter {
        buildCommonCallsCount += 1
        buildCommonInvocations.append(cellType)

        buildCellTypeCallsCount += 1
        let arguments = cellType
        buildCellTypeReceivedArguments = arguments
        buildCellTypeReceivedInvocations.append(arguments)
        return buildCellTypeReturnValue
    }

    // MARK: - buildCellTypeAction

    typealias BuildCellTypeActionArguments = (cellType: SBPBankCellType, action: VoidBlock)

    var buildCellTypeActionCallsCount = 0
    var buildCellTypeActionReceivedArguments: BuildCellTypeActionArguments?
    var buildCellTypeActionReceivedInvocations: [BuildCellTypeActionArguments?] = []
    var buildCellTypeActionShouldExecute = false
    var buildCellTypeActionReturnValue: ISBPBankCellPresenter!

    func build(cellType: SBPBankCellType, action: @escaping VoidBlock) -> ISBPBankCellPresenter {
        buildCommonCallsCount += 1
        buildCommonInvocations.append(cellType)

        buildCellTypeActionCallsCount += 1
        let arguments = (cellType, action)
        buildCellTypeActionReceivedArguments = arguments
        buildCellTypeActionReceivedInvocations.append(arguments)
        if buildCellTypeActionShouldExecute {
            action()
        }
        return buildCellTypeActionReturnValue
    }
}

// MARK: - Resets

extension SBPBankCellPresenterAssemblyMock {
    func fullReset() {
        buildCommonCallsCount = 0
        buildCommonInvocations = []

        buildCellTypeCallsCount = 0
        buildCellTypeReceivedArguments = nil
        buildCellTypeReceivedInvocations = []

        buildCellTypeActionCallsCount = 0
        buildCellTypeActionReceivedArguments = nil
        buildCellTypeActionReceivedInvocations = []
        buildCellTypeActionShouldExecute = false
    }
}
