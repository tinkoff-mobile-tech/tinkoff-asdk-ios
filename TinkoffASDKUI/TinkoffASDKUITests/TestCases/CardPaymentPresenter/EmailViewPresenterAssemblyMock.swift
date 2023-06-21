//
//  EmailViewPresenterAssemblyMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 23.05.2023.
//

@testable import TinkoffASDKUI

final class EmailViewPresenterAssemblyMock: IEmailViewPresenterAssembly {

    // MARK: - build

    typealias BuildArguments = (customerEmail: String, output: IEmailViewPresenterOutput)

    var buildCallsCount = 0
    var buildReceivedArguments: BuildArguments?
    var buildReceivedInvocations: [BuildArguments] = []
    var buildReturnValue: IEmailViewOutput = EmailViewOutputMock()

    func build(customerEmail: String, output: IEmailViewPresenterOutput) -> IEmailViewOutput {
        buildCallsCount += 1
        let arguments = (customerEmail, output)
        buildReceivedArguments = arguments
        buildReceivedInvocations.append(arguments)
        return buildReturnValue
    }
}
