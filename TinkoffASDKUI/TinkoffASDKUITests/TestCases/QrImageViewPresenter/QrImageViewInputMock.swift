//
//  QrImageViewInputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 17.05.2023.
//

import Foundation

@testable import TinkoffASDKUI

final class QrImageViewInputMock: IQrImageViewInput {

    // MARK: - set

    var setQrCodeHTMLCallsCount = 0
    var setQrCodeHTMLReceivedArguments: String?
    var setQrCodeHTMLReceivedInvocations: [String] = []

    func set(qrCodeHTML: String) {
        setQrCodeHTMLCallsCount += 1
        let arguments = qrCodeHTML
        setQrCodeHTMLReceivedArguments = arguments
        setQrCodeHTMLReceivedInvocations.append(arguments)
    }

    // MARK: - set

    var setQrCodeUrlCallsCount = 0
    var setQrCodeUrlReceivedArguments: String?
    var setQrCodeUrlReceivedInvocations: [String] = []

    func set(qrCodeUrl: String) {
        setQrCodeUrlCallsCount += 1
        let arguments = qrCodeUrl
        setQrCodeUrlReceivedArguments = arguments
        setQrCodeUrlReceivedInvocations.append(arguments)
    }
}
