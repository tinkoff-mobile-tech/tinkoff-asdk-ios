//
//  Logger.swift
//  TinkoffASDKCore
//
//  Copyright (c) 2020 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

public class Logger {
    // MARK: Properties

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()

    // MARK: Initialization

    public init() {}
}

// MARK: - ILogger

extension Logger: ILogger {
    public func log(_ value: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(with: value, type: .common, file: file, function: function, line: line)
    }

    public func log(request: URLRequest, file: String = #file, function: String = #function, line: Int = #line) {
        let urlAsString = request.url?.absoluteString ?? ""
        let urlComponents = URLComponents(string: urlAsString)
        let method = request.httpMethod ?? ""
        let path = urlComponents?.path ?? ""
        let query = urlComponents?.query ?? ""
        let host = urlComponents?.host ?? ""

        var output = "\(urlAsString) \n\n\(method) \(path)?\(query) HTTP/1.1 \nHOST: \(host)\n"
        request.allHTTPHeaderFields?.forEach { output += "\($0): \($1)\n" }
        if let bodyData = request.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
            output += "\n\(bodyString)\n"
        }

        log(with: output, type: .request, file: file, function: function, line: line)
    }

    public func log(
        request: URLRequest,
        result: Result<(HTTPURLResponse, Data), Error>,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        switch result {
        case let .success((response, data)):
            log(response: response, data: data, file: file, function: function, line: line)
        case let .failure(error):
            log(request: request, error: error, file: file, function: function, line: line)
        }
    }
}

// MARK: - Private

extension Logger {
    private func log(with value: String, type: LogType, file: String, function: String, line: Int) {
        let time = timeFormatter.string(from: Date())
        defer { print("\n - - - - - - - - - - ASDK \(type.logFinishName) (\(time)) - - - - - - - - - - \n") }

        let currentThread = Thread.current
        let threadName = currentThread.isMainThread ? "Main thread" : currentThread.description
        let fileName = file.split(separator: "/").last ?? ""
        print("\n - - - - - - - - - - ASDK \(type.logStartName) (\(time)) - - - - - - - - - -")
        print("on \(threadName), in \(fileName), func \(function), at line: \(line)\n")
        print(value)
    }

    private func log(request: URLRequest, error: Error, file: String, function: String, line: Int) {
        let urlAsString = request.url?.absoluteString ?? ""
        let output = "\(urlAsString)\n\nError: \(error.localizedDescription)\n"
        log(with: output, type: .networkError, file: file, function: function, line: line)
    }

    private func log(response: HTTPURLResponse, data: Data, file: String, function: String, line: Int) {
        let urlAsString = response.url?.absoluteString ?? ""
        let urlComponents = NSURLComponents(string: urlAsString)
        let path = urlComponents?.path ?? ""
        let query = urlComponents?.query ?? ""
        let host = urlComponents?.host ?? ""

        var output = "\(urlAsString)\n\nHTTP \(response.statusCode) \(path)?\(query)\nHost: \(host)\n"
        response.allHeaderFields.forEach { output += "\($0): \($1)\n" }
        if let bodyString = String(data: data, encoding: .utf8) {
            output += "\n\(bodyString)\n"
        }

        log(with: output, type: .response, file: file, function: function, line: line)
    }
}
