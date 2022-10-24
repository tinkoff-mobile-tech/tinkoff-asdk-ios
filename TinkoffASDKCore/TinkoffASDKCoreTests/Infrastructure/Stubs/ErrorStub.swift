//
//  ErrorStub.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 24.10.2022.
//

import Foundation

struct ErrorStub: Error, Equatable {
    let description: String

    init(description: String = #function) {
        self.description = description
    }
}
