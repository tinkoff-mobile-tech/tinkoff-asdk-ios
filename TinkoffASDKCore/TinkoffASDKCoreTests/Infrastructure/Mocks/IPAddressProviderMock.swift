//
//  IPAddressProviderMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 21.07.2023.
//

import Foundation
@testable import TinkoffASDKCore

final class IPAddressProviderMock: IIPAddressProvider {
    var ipAddress: IPAddress?
}
