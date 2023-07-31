//
//  PublicKeyProviderMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 21.07.2023.
//

import Foundation
@testable import TinkoffASDKCore

final class PublicKeyProviderMock: IPublicKeyProvider {

    var publicKey: SecKey {
        get { return underlyingPublicKey }
        set(value) { underlyingPublicKey = value }
    }

    var underlyingPublicKey: SecKey!
}
