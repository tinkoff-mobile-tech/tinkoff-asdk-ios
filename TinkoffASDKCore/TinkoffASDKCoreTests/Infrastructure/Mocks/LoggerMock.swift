//
//  LoggerMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 22.03.2023.
//

import Foundation
@testable import TinkoffASDKCore

final class LoggerMock: ILogger {

    // MARK: - logFile

    typealias LogFileArguments = (value: String, file: String, function: String, line: Int)

    var logFileCallsCount = 0
    var logFileReceivedArguments: LogFileArguments?
    var logFileReceivedInvocations: [LogFileArguments?] = []

    func log(_ value: String, file: String, function: String, line: Int) {
        logFileCallsCount += 1
        let arguments = (value, file, function, line)
        logFileReceivedArguments = arguments
        logFileReceivedInvocations.append(arguments)
    }

    // MARK: - logRequestFile

    typealias LogRequestFileArguments = (request: URLRequest, file: String, function: String, line: Int)

    var logRequestFileCallsCount = 0
    var logRequestFileReceivedArguments: LogRequestFileArguments?
    var logRequestFileReceivedInvocations: [LogRequestFileArguments?] = []

    func log(request: URLRequest, file: String, function: String, line: Int) {
        logRequestFileCallsCount += 1
        let arguments = (request, file, function, line)
        logRequestFileReceivedArguments = arguments
        logRequestFileReceivedInvocations.append(arguments)
    }

    // MARK: - logRequestResult

    typealias LogRequestResultArguments = (request: URLRequest, result: Result<(HTTPURLResponse, Data), Error>, file: String, function: String, line: Int)

    var logRequestResultCallsCount = 0
    var logRequestResultReceivedArguments: LogRequestResultArguments?
    var logRequestResultReceivedInvocations: [LogRequestResultArguments?] = []

    func log(request: URLRequest, result: Result<(HTTPURLResponse, Data), Error>, file: String, function: String, line: Int) {
        logRequestResultCallsCount += 1
        let arguments = (request, result, file, function, line)
        logRequestResultReceivedArguments = arguments
        logRequestResultReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension LoggerMock {
    func fullReset() {
        logFileCallsCount = 0
        logFileReceivedArguments = nil
        logFileReceivedInvocations = []

        logRequestFileCallsCount = 0
        logRequestFileReceivedArguments = nil
        logRequestFileReceivedInvocations = []

        logRequestResultCallsCount = 0
        logRequestResultReceivedArguments = nil
        logRequestResultReceivedInvocations = []
    }
}
