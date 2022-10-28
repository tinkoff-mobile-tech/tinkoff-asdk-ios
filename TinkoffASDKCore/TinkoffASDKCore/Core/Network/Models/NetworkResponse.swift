//
//  NetworkResponse.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 09.10.2022.
//

import Foundation

struct NetworkResponse {
    let urlRequest: URLRequest
    let httpResponse: HTTPURLResponse
    let data: Data
}
