//
//  TextAndImageHeaderViewPresenterAssemblyMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 13.06.2023.
//

@testable import TinkoffASDKUI

final class TextAndImageHeaderViewPresenterAssemblyMock: ITextAndImageHeaderViewPresenterAssembly {

    // MARK: - build

    typealias BuildArguments = (title: String, imageAsset: ImageAsset?)

    var buildCallsCount = 0
    var buildReceivedArguments: BuildArguments?
    var buildReceivedInvocations: [BuildArguments] = []
    var buildReturnValue = TextAndImageHeaderViewOutputMock()

    func build(title: String, imageAsset: ImageAsset?) -> any ITextAndImageHeaderViewOutput {
        buildCallsCount += 1
        let arguments = (title, imageAsset)
        buildReceivedArguments = arguments
        buildReceivedInvocations.append(arguments)
        return buildReturnValue
    }
}
