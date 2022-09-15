//
//  IPAddressValidator.swift
//  TinkoffASDKCore
//
//  Created by grisha on 09.12.2020.
//

import Foundation

struct IPAddressValidator {
    
    enum IPAddressType {
        case v4
        case v6
    }
    
    func validateIPAddress(_ ipAddress: String, type: IPAddressType) -> Bool {
        let result: Int32
        switch type {
        case .v4:
            result = validateIPv4Address(ipAddress)
        case .v6:
            result = validateIPv6Address(ipAddress)
        }
        
        switch result {
        case let value where value <= 0:
            return false
        default:
            return true
        }
    }
}

private extension IPAddressValidator {
    func validateIPv4Address(_ ipAddress: String) -> Int32 {
        var address = in_addr()
        return withUnsafeMutablePointer(to: &address) {
            inet_pton(AF_INET, ipAddress, $0)
        }
    }
    
    func validateIPv6Address(_ ipAddress: String) -> Int32 {
        var address = in6_addr()
        return withUnsafeMutablePointer(to: &address) {
            inet_pton(AF_INET6, ipAddress, $0)
        }
    }
}
