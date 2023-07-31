//
//  IPAddressProviderMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 21.07.2023.
//

import Foundation
@testable import TinkoffASDKCore

public final class IPAddressProviderMock: IIPAddressProvider {
    public init() {}
    public var ipAddress: IPAddress?
}
