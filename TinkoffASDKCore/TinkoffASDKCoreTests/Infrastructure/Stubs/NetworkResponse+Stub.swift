//
//  NetworkResponse+Stub.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 24.10.2022.
//

import Foundation
@testable import TinkoffASDKCore

extension NetworkResponse {
    static func stub(
        urlRequest: URLRequest = URLRequest(url: .doesNotMatter),
        httpResponse: HTTPURLResponse = HTTPURLResponse(
            url: .doesNotMatter,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!,
        data: Data = Data()
    ) -> NetworkResponse {
        NetworkResponse(urlRequest: urlRequest, httpResponse: httpResponse, data: data)
    }
}
