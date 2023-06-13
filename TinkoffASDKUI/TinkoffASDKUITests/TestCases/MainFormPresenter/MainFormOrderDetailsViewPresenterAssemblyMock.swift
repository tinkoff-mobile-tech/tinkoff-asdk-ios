//
//  MainFormOrderDetailsViewPresenterAssemblyMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 13.06.2023.
//

@testable import TinkoffASDKUI

final class MainFormOrderDetailsViewPresenterAssemblyMock: IMainFormOrderDetailsViewPresenterAssembly {

    // MARK: - build

    typealias BuildArguments = (amount: Int64, orderDescription: String?)

    var buildCallsCount = 0
    var buildReceivedArguments: BuildArguments?
    var buildReceivedInvocations: [BuildArguments] = []
    var buildReturnValue = MainFormOrderDetailsViewOutputMock()

    func build(amount: Int64, orderDescription: String?) -> any IMainFormOrderDetailsViewOutput {
        buildCallsCount += 1
        let arguments = (amount, orderDescription)
        buildReceivedArguments = arguments
        buildReceivedInvocations.append(arguments)
        return buildReturnValue
    }
}
