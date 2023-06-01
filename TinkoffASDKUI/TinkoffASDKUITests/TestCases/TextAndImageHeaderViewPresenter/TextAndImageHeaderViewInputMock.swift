//
//  TextAndImageHeaderViewInputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 29.05.2023.
//

@testable import TinkoffASDKUI

final class TextAndImageHeaderViewInputMock: ITextAndImageHeaderViewInput {

    // MARK: - set

    var setTitleCallsCount = 0
    var setTitleReceivedArguments: String?
    var setTitleReceivedInvocations: [String?] = []

    func set(title: String?) {
        setTitleCallsCount += 1
        let arguments = title
        setTitleReceivedArguments = arguments
        setTitleReceivedInvocations.append(arguments)
    }

    // MARK: - set

    var setImageCallsCount = 0
    var setImageReceivedArguments: UIImage?
    var setImageReceivedInvocations: [UIImage?] = []

    func set(image: UIImage?) {
        setImageCallsCount += 1
        let arguments = image
        setImageReceivedArguments = arguments
        setImageReceivedInvocations.append(arguments)
    }
}

// MARK: - Public methods

extension TextAndImageHeaderViewInputMock {
    func fullReset() {
        setTitleCallsCount = 0
        setTitleReceivedArguments = nil
        setTitleReceivedInvocations = []

        setImageCallsCount = 0
        setImageReceivedArguments = nil
        setImageReceivedInvocations = []
    }
}
