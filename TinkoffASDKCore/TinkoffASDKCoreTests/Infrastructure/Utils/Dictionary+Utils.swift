//
//  Dictionary+Utils.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 25.10.2022.
//

import Foundation

extension Dictionary where Value == Any {
    func isEqual(to other: [Key: Value]) -> Bool {
        NSDictionary(dictionary: self).isEqual(to: other)
    }
}
