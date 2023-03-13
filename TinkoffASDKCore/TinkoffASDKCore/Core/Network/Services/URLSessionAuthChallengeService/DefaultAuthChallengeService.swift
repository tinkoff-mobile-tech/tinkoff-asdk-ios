//
//  DefaultAuthChallengeService.swift
//  TinkoffASDKCore
//
//  Created by Aleksandr Pravosudov on 13.03.2023.
//

open class DefaultAuthChallengeService {
    // MARK: Properties

    private let certificateValidator: ICertificateValidator

    // MARK: Initialization

    public init(certificateValidator: ICertificateValidator) {
        self.certificateValidator = certificateValidator
    }

    // MARK: Public

    public func didReceive(
        challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            return completionHandler(.performDefaultHandling, nil)
        }

        if certificateValidator.isValid(serverTrust: serverTrust) {
            let cred = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, cred)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
