//
//  IPAddressFactory.swift
//  Pods
//
//  Created by grisha on 09.12.2020.
//

import Foundation

struct IPAddressFactory {
    func ipAddress(with string: String) -> IPAddress? {
        IPv4Address(string) ?? IPv6Address(string)
    }
}
