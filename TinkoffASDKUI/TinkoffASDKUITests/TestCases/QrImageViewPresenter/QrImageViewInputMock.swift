//
//  QrImageViewInputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 17.05.2023.
//

import Foundation
@testable import TinkoffASDKUI

final class QrImageViewInputMock: IQrImageViewInput {

    // MARK: - setQrCodeHTML

    typealias SetQrCodeHTMLArguments = String

    var setQrCodeHTMLCallsCount = 0
    var setQrCodeHTMLReceivedArguments: SetQrCodeHTMLArguments?
    var setQrCodeHTMLReceivedInvocations: [SetQrCodeHTMLArguments?] = []

    func set(qrCodeHTML: String) {
        setQrCodeHTMLCallsCount += 1
        let arguments = qrCodeHTML
        setQrCodeHTMLReceivedArguments = arguments
        setQrCodeHTMLReceivedInvocations.append(arguments)
    }

    // MARK: - setQrCodeUrl

    typealias SetQrCodeUrlArguments = String

    var setQrCodeUrlCallsCount = 0
    var setQrCodeUrlReceivedArguments: SetQrCodeUrlArguments?
    var setQrCodeUrlReceivedInvocations: [SetQrCodeUrlArguments?] = []

    func set(qrCodeUrl: String) {
        setQrCodeUrlCallsCount += 1
        let arguments = qrCodeUrl
        setQrCodeUrlReceivedArguments = arguments
        setQrCodeUrlReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension QrImageViewInputMock {
    func fullReset() {
        setQrCodeHTMLCallsCount = 0
        setQrCodeHTMLReceivedArguments = nil
        setQrCodeHTMLReceivedInvocations = []

        setQrCodeUrlCallsCount = 0
        setQrCodeUrlReceivedArguments = nil
        setQrCodeUrlReceivedInvocations = []
    }
}
