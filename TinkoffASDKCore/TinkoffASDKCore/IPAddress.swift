//
//  IPAddress.swift
//  TinkoffASDKCore
//
//  Created by grisha on 09.12.2020.
//

import Foundation

protocol IPAddress {
    var stringValue: String { get }
    var fullStringValue: String { get }
    
    init?(_ stringValue: String)
}
