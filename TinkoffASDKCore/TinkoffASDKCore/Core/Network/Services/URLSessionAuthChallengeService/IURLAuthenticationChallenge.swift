//
//  IURLAuthenticationChallenge.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 01.08.2023.
//

import Foundation

public protocol IURLAuthenticationChallenge {
    var protectionSpace: URLProtectionSpace { get }
}

extension URLAuthenticationChallenge: IURLAuthenticationChallenge {}
