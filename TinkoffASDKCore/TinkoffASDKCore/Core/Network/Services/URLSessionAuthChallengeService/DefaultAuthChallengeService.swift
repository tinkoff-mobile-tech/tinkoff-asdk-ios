//
//  DefaultAuthChallengeService.swift
//  TinkoffASDKCore
//
//  Created by Aleksandr Pravosudov on 13.03.2023.
//

import Foundation

open class DefaultAuthChallengeService {
    // MARK: Properties

    private let certificateValidator: ICertificateValidator

    // MARK: Initialization

    public init(certificateValidator: ICertificateValidator) {
        self.certificateValidator = certificateValidator
    }

    // MARK: Public

    public func didReceive(
        challenge: IURLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        DispatchQueue.global().async {
            guard let serverTrust = challenge.protectionSpace.serverTrust else {
                return completionHandler(.performDefaultHandling, nil)
            }

            if self.certificateValidator.isValid(serverTrust: serverTrust) {
                let cred = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, cred)
            } else {
                completionHandler(.performDefaultHandling, nil)
            }
        }
    }
}
