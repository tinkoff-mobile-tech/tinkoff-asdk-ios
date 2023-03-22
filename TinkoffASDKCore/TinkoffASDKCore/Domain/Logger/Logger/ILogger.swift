//
//  ILogger.swift
//  TinkoffASDKCore
//
//  Created by Aleksandr Pravosudov on 22.03.2023.
//

import Foundation

public protocol ILogger {
    func log(_ value: String, file: String, function: String, line: Int)
    func log(request: URLRequest, file: String, function: String, line: Int)
    func log(request: URLRequest, result: Result<(HTTPURLResponse, Data), Error>, file: String, function: String, line: Int)
}

public extension ILogger {
    func log(_ value: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(value, file: file, function: function, line: line)
    }

    func log(request: URLRequest, file: String = #file, function: String = #function, line: Int = #line) {
        log(request: request, file: file, function: function, line: line)
    }

    func log(
        request: URLRequest,
        result: Result<(HTTPURLResponse, Data), Error>,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(request: request, result: result, file: file, function: function, line: line)
    }
}
