//
//  PublicKeyProvider.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 06.10.2022.
//

import Foundation

protocol IPublicKeyProvider {
    var publicKey: SecKey { get }
}

final class PublicKeyProvider: IPublicKeyProvider {
    let publicKey: SecKey

    init?(string: String) {
        guard let secKey = RSAEncryption.secKey(string: string) else {
            return nil
        }

        publicKey = secKey
    }
}
