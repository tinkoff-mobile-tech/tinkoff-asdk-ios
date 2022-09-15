//
//  IPv6Address.swift
//  TinkoffASDKCore
//
//  Created by grisha on 09.12.2020.
//

import Foundation

struct IPv6Address: IPAddress {
    var stringValue: String
    
    var fullStringValue: String {
        return resolveFullStringValue()
    }
    
    init?(_ stringValue: String) {
        let validator = IPAddressValidator()
        guard validator.validateIPAddress(stringValue, type: .v6) else {
            return nil
        }
        self.stringValue = stringValue
    }
}

private extension IPv6Address {
    func resolveFullStringValue() -> String {
        let segments = stringValue.components(separatedBy: ":")
        var fullAddressSegments = [String]()
        segments.forEach { segment in
            guard !segment.isEmpty else {
                fullAddressSegments.append(contentsOf: Array(repeating: String.omittedSegment, count: .ipv6FullSegmentsCount - segments.count + 1))
                return
            }
            
            if segment.count < .ipv6OneSegmentElementsCount {
                let missedZeroes = String(Array(repeating: "0", count: .ipv6OneSegmentElementsCount - segment.count))
                let enrichedSegment = missedZeroes + segment
                fullAddressSegments.append(enrichedSegment)
            } else {
                fullAddressSegments.append(segment)
            }
        }
        
        return fullAddressSegments.joined(separator: ":")
    }
}

private extension Int {
    static let ipv6FullSegmentsCount = 8
    static let ipv6OneSegmentElementsCount = 4
}

private extension String {
    static let omittedSegment: String = "0000"
}
