//
//  StringProvider.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 06.10.2022.
//

import Foundation

protocol IStringProvider {
    var value: String { get }
}

final class StringProvider: IStringProvider {
    let value: String

    init(value: String) {
        self.value = value
    }
}
