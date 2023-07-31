//
//  ThreeDSFacadeMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 26.07.2023.
//

import Foundation
@testable import TinkoffASDKCore

final class ThreeDSFacadeMock: IThreeDSURLBuilder & IThreeDSURLRequestBuilder & IThreeDSWebViewHandlerBuilder & IThreeDSDeviceParamsProviderBuilder {
    // MARK: - url

    typealias UrlArguments = ThreeDSURLType

    var urlCallsCount = 0
    var urlReceivedArguments: UrlArguments?
    var urlReceivedInvocations: [UrlArguments?] = []
    var urlReturnValue: URL!

    func url(ofType type: ThreeDSURLType) -> URL {
        urlCallsCount += 1
        let arguments = type
        urlReceivedArguments = arguments
        urlReceivedInvocations.append(arguments)
        return urlReturnValue
    }

    // MARK: - buildConfirmation3DSRequestACS

    typealias BuildConfirmation3DSRequestACSArguments = (requestData: Confirmation3DSDataACS, version: String)

    var buildConfirmation3DSRequestACSThrowableError: Error?
    var buildConfirmation3DSRequestACSCallsCount = 0
    var buildConfirmation3DSRequestACSReceivedArguments: BuildConfirmation3DSRequestACSArguments?
    var buildConfirmation3DSRequestACSReceivedInvocations: [BuildConfirmation3DSRequestACSArguments?] = []
    var buildConfirmation3DSRequestACSReturnValue: URLRequest!

    func buildConfirmation3DSRequestACS(requestData: Confirmation3DSDataACS, version: String) throws -> URLRequest {
        if let error = buildConfirmation3DSRequestACSThrowableError {
            throw error
        }
        buildConfirmation3DSRequestACSCallsCount += 1
        let arguments = (requestData, version)
        buildConfirmation3DSRequestACSReceivedArguments = arguments
        buildConfirmation3DSRequestACSReceivedInvocations.append(arguments)
        return buildConfirmation3DSRequestACSReturnValue
    }

    // MARK: - buildConfirmation3DSRequest

    typealias BuildConfirmation3DSRequestArguments = Confirmation3DSData

    var buildConfirmation3DSRequestThrowableError: Error?
    var buildConfirmation3DSRequestCallsCount = 0
    var buildConfirmation3DSRequestReceivedArguments: BuildConfirmation3DSRequestArguments?
    var buildConfirmation3DSRequestReceivedInvocations: [BuildConfirmation3DSRequestArguments?] = []
    var buildConfirmation3DSRequestReturnValue: URLRequest!

    func buildConfirmation3DSRequest(requestData: Confirmation3DSData) throws -> URLRequest {
        if let error = buildConfirmation3DSRequestThrowableError {
            throw error
        }
        buildConfirmation3DSRequestCallsCount += 1
        let arguments = requestData
        buildConfirmation3DSRequestReceivedArguments = arguments
        buildConfirmation3DSRequestReceivedInvocations.append(arguments)
        return buildConfirmation3DSRequestReturnValue
    }

    // MARK: - build3DSCheckURLRequest

    typealias Build3DSCheckURLRequestArguments = Checking3DSURLData

    var build3DSCheckURLRequestThrowableError: Error?
    var build3DSCheckURLRequestCallsCount = 0
    var build3DSCheckURLRequestReceivedArguments: Build3DSCheckURLRequestArguments?
    var build3DSCheckURLRequestReceivedInvocations: [Build3DSCheckURLRequestArguments?] = []
    var build3DSCheckURLRequestReturnValue: URLRequest!

    func build3DSCheckURLRequest(requestData: Checking3DSURLData) throws -> URLRequest {
        if let error = build3DSCheckURLRequestThrowableError {
            throw error
        }
        build3DSCheckURLRequestCallsCount += 1
        let arguments = requestData
        build3DSCheckURLRequestReceivedArguments = arguments
        build3DSCheckURLRequestReceivedInvocations.append(arguments)
        return build3DSCheckURLRequestReturnValue
    }

    // MARK: - threeDSWebViewHandler

    var threeDSWebViewHandlerCallsCount = 0
    var threeDSWebViewHandlerReturnValue: IThreeDSWebViewHandler!

    func threeDSWebViewHandler() -> IThreeDSWebViewHandler {
        threeDSWebViewHandlerCallsCount += 1
        return threeDSWebViewHandlerReturnValue
    }

    // MARK: - threeDSDeviceInfoProvider

    var threeDSDeviceInfoProviderCallsCount = 0
    var threeDSDeviceInfoProviderReturnValue: IThreeDSDeviceInfoProvider!

    func threeDSDeviceInfoProvider() -> IThreeDSDeviceInfoProvider {
        threeDSDeviceInfoProviderCallsCount += 1
        return threeDSDeviceInfoProviderReturnValue
    }
}
