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

    init?(string: String, encryptor: IRSAEncryptor) {
        guard let secKey = encryptor.createPublicSecKey(publicKey: string) else {
            return nil
        }

        publicKey = secKey
    }
}
