//
//  LoggerMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 22.03.2023.
//

import Foundation
@testable import TinkoffASDKCore

final class LoggerMock: ILogger {
    func log(_ value: String, file: String, function: String, line: Int) {}
    func log(request: URLRequest, file: String, function: String, line: Int) {}
    func log(request: URLRequest, result: Result<NetworkResponse, NetworkError>, file: String, function: String, line: Int) {}
}
