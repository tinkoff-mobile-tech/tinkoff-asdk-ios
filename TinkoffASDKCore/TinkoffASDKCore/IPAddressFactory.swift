//
//  IPAddressFactory.swift
//  Pods
//
//  Created by grisha on 09.12.2020.
//

import Foundation

struct IPAddressFactory {
    func ipAddress(with string: String) -> IPAddress? {
        if let ipv4Address = IPv4Address(string) {
            return ipv4Address
        } else if let ipv6Address = IPv6Address(string) {
            return ipv6Address
        } else {
            return nil
        }
    }
}
