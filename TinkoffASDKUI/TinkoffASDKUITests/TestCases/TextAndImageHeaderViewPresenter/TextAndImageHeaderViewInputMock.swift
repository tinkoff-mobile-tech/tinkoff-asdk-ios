//
//  TextAndImageHeaderViewInputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 29.05.2023.
//

@testable import TinkoffASDKUI
import UIKit

final class TextAndImageHeaderViewInputMock: ITextAndImageHeaderViewInput {

    // MARK: - setTitle

    typealias SetTitleArguments = String

    var setTitleCallsCount = 0
    var setTitleReceivedArguments: SetTitleArguments?
    var setTitleReceivedInvocations: [SetTitleArguments?] = []

    func set(title: String?) {
        setTitleCallsCount += 1
        let arguments = title
        setTitleReceivedArguments = arguments
        setTitleReceivedInvocations.append(arguments)
    }

    // MARK: - setImage

    typealias SetImageArguments = UIImage

    var setImageCallsCount = 0
    var setImageReceivedArguments: SetImageArguments?
    var setImageReceivedInvocations: [SetImageArguments?] = []

    func set(image: UIImage?) {
        setImageCallsCount += 1
        let arguments = image
        setImageReceivedArguments = arguments
        setImageReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

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
