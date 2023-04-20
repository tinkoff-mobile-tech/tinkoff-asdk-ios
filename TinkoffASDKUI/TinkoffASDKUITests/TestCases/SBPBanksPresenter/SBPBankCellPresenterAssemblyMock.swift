//
//  SBPBankCellPresenterAssemblyMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 20.04.2023.
//

@testable import TinkoffASDKUI

final class ISBPBankCellPresenterAssemblyMock: ISBPBankCellPresenterAssembly {

    // MARK: - build

    var buildCallsCount = 0
    var buildReceivedArguments: SBPBankCellType?
    var buildReceivedInvocations: [SBPBankCellType] = []
    var buildReturnValue: SBPBankCellPresenter!

    func build(cellType: SBPBankCellType) -> SBPBankCellPresenter {
        buildCallsCount += 1
        let arguments = cellType
        buildReceivedArguments = arguments
        buildReceivedInvocations.append(arguments)
        return buildReturnValue
    }

    // MARK: - build

    var buildWithActionCallsCount = 0
    var buildWithActionReceivedArguments: SBPBankCellType?
    var buildWithActionReceivedInvocations: [SBPBankCellType] = []
    var buildWithActionActionShouldCalls = false
    var buildWithActionReturnValue: SBPBankCellPresenter!

    func build(cellType: SBPBankCellType, action: @escaping VoidBlock) -> SBPBankCellPresenter {
        buildWithActionCallsCount += 1
        let arguments = cellType
        buildWithActionReceivedArguments = arguments
        buildWithActionReceivedInvocations.append(arguments)
        if buildWithActionActionShouldCalls {
            action()
        }
        return buildWithActionReturnValue
    }
}
