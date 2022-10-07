//
//  AcquiringLoggerDefault.swift
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

public protocol LoggerDelegate: AnyObject {
    func log(_ value: String, file: String, function: String, line: Int, thread: Thread)
}

public extension LoggerDelegate {
    func log(_ value: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(value, file: file, function: function, line: line, thread: .current)
    }
}

public class AcquiringLoggerDefault: NSObject, LoggerDelegate {
    public func log(_ value: String, file: String = #file, function: String = #function, line: Int = #line, thread: Thread = .current) {
        let fileName = file.split(separator: "/").last ?? ""
        let threadName = thread.isMainThread ? "Main thread" : thread.description

        Swift.print("[ASDK ->]: on \(threadName), in \(fileName), func \(function), at line: \(line) do:")
        Swift.print(value, separator: ", ", terminator: "\n")
    }
}
