//
//  JSONStub.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 30.11.2022.
//

import Foundation
import XCTest

struct JSONStub {
    let fileName: String

    init(_ fileName: String) {
        self.fileName = fileName
    }

    func data() throws -> Data {
        let data = try Bundle
            .testResources
            .url(forResource: fileName, withExtension: .jsonExtension)
            .map { try Data(contentsOf: $0) }

        return try XCTUnwrap(data)
    }
}

// MARK: - String + Constants

private extension String {
    static let jsonExtension = "json"
}
