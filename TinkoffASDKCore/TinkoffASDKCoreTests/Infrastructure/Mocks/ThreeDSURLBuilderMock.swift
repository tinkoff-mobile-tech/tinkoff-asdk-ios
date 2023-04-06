//
//  ThreeDSURLBuilderMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Ivan Glushko on 27.03.2023.
//

import Foundation
@testable import TinkoffASDKCore

final class ThreeDSURLBuilderMock: IThreeDSURLBuilder {

    // MARK: - url

    var urlCallsCount = 0
    var urlReceivedArguments: ThreeDSURLType?
    var urlReceivedInvocations: [ThreeDSURLType] = []
    var urlReturnValue: URL!

    func url(ofType type: ThreeDSURLType) -> URL {
        urlCallsCount += 1
        let arguments = type
        urlReceivedArguments = arguments
        urlReceivedInvocations.append(arguments)
        return urlReturnValue
    }
}
