//
//  SBPBankCellPresenterAssemblyMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 20.04.2023.
//

@testable import TinkoffASDKUI

final class ISBPBankCellPresenterAssemblyMock: ISBPBankCellPresenterAssembly {

    var buildCommonCallsCount = 0
    var buildCommonInvocations: [SBPBankCellType] = []

    // MARK: - build

    var buildCallsCount = 0
    var buildReceivedArguments: SBPBankCellType?
    var buildReceivedInvocations: [SBPBankCellType] = []
    var buildReturnValue: ISBPBankCellPresenter!

    func build(cellType: SBPBankCellType) -> ISBPBankCellPresenter {
        buildCommonCallsCount += 1
        buildCallsCount += 1
        let arguments = cellType
        buildReceivedArguments = arguments
        buildReceivedInvocations.append(arguments)
        buildCommonInvocations.append(arguments)
        return buildReturnValue
    }

    // MARK: - build

    typealias BuildWithActionArguments = (cellType: SBPBankCellType, action: VoidBlock)

    var buildWithActionCallsCount = 0
    var buildWithActionReceivedArguments: BuildWithActionArguments?
    var buildWithActionReceivedInvocations: [BuildWithActionArguments] = []
    var buildWithActionReturnValue: ISBPBankCellPresenter!

    func build(cellType: SBPBankCellType, action: @escaping VoidBlock) -> ISBPBankCellPresenter {
        buildCommonCallsCount += 1
        buildWithActionCallsCount += 1
        let arguments = (cellType, action)
        buildWithActionReceivedArguments = arguments
        buildWithActionReceivedInvocations.append(arguments)
        buildCommonInvocations.append(cellType)
        return buildWithActionReturnValue
    }
}
