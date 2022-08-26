//
//  NetworkTransport.swift
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

// MARK: NetworkTransport

protocol NetworkTransport: AnyObject {
    var confirmation3DSTerminationURL: URL { get }
    var confirmation3DSTerminationV2URL: URL { get }
    var complete3DSMethodV2URL: URL { get }

    func createConfirmation3DSRequest(requestData: Confirmation3DSData) throws -> URLRequest
    func createConfirmation3DSRequestACS(requestData: Confirmation3DSDataACS, messageVersion: String) throws -> URLRequest
    func createChecking3DSURL(requestData: Checking3DSURLData) throws -> URLRequest
    func myIpAddress() -> String?
    func send<Operation: RequestOperation, Response: ResponseOperation>(
        operation: Operation,
        responseDelegate: NetworkTransportResponseDelegate?,
        completionHandler: @escaping (_ results: Result<Response, Error>) -> Void
    ) -> Cancellable
    func sendCertsConfigRequest<Operation: RequestOperation>(operation: Operation,
                                                             completionHandler: @escaping (_ results: Result<GetCertsConfigResponse, Error>) -> Void) -> Cancellable
}

extension NetworkTransport {
    /// используется для большинства запросов, обработка ответа происходит по стандартному сценарию, responseDelegate = nil
    func send<Operation: RequestOperation, Response: ResponseOperation>(
        operation: Operation,
        completionHandler: @escaping (_ results: Result<Response, Error>) -> Void
    ) -> Cancellable {
        send(operation: operation, responseDelegate: nil, completionHandler: completionHandler)
    }
}

// MARK: NetworkTransportResponseDelegate

public protocol NetworkTransportResponseDelegate {
    /// Делегирование обработки ответа сервера
    /// NetworkTransport проверяет ошибки сети, HTTP Status Code `200..<300` и наличие данных
    /// далее передает обработку данных делегату
    func networkTransport(
        didCompleteRawTaskForRequest request: URLRequest,
        withData data: Data,
        response: URLResponse,
        error: Error?
    ) throws -> ResponseOperation
}

// MARK: AcquaringNetworkTransport

final class AcquaringNetworkTransport: NetworkTransport {
    private let urlDomain: URL
    private let certsConfigDomain: URL
    private let apiPathV2: String = "v2"
    private let apiPathV1: String = "rest"
    private let session: URLSession
    private let serializationFormat = JSONSerializationFormat.self
    private let deviceInfo: DeviceInfo
    private let logger: LoggerDelegate?

    /// Экземпляр класса для работы с сетью, создает сетевые запросы, разбирает полученные данные от сервера.
    ///
    /// - Parameters:
    ///   - url: путь к серверу **Tinkoff Acquaring API**
    ///   - certsConfig - путь к конфигу с сертификатами
    ///   - session: конфигурация URLSession по умолчанию используеться `URLSession.shared`,
    init(urlDomain: URL, certsConfigDomain: URL, session: URLSession = .shared, deviceInfo: DeviceInfo, logger: LoggerDelegate? = nil) {
        self.urlDomain = urlDomain
        self.certsConfigDomain = certsConfigDomain
        self.session = session
        self.deviceInfo = deviceInfo
        self.logger = logger
    }

    private func createRequest<Operation: RequestOperation>(domain: URL, for operation: Operation) throws -> URLRequest {
        var request = URLRequest(url: domain.appendingPathComponent(operation.name))
        request.setValue(operation.requestContentType.rawValue, forHTTPHeaderField: "Content-Type")
        request.httpMethod = operation.requestMethod.rawValue

        if let body = operation.parameters {
            logger?.log("🛫 Start \(operation.requestMethod.rawValue) request: \(request.description), with paramaters: \(body)")
            switch operation.requestContentType {
            case .applicationJson:
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [.sortedKeys])
            case .urlEncoded:
                request.httpBody = generateBodyParamsString(using: body).data(using: .utf8)
            }
        } else {
            logger?.log("🛫 Start \(operation.requestMethod.rawValue) request: \(request.description)")
        }

        return request
    }

    /// Во время прохождения 3DS v1 WKNavigationDelegate отслеживает редиректы формы 3DS,
    /// этот url считается конечным в сценарии прохождения 3DS
    ///
    /// - Returns: URL
    private(set) lazy var confirmation3DSTerminationURL: URL = {
        self.urlDomain.appendingPathComponent(self.apiPathV1).appendingPathComponent("Submit3DSAuthorization")
    }()

    /// Во время проверки `threeDSMethodCheckURL` девайса и параметров оплаты, какой версией
    /// метода 3DS нужно воспользоваться, этот url используется как параметр `cresCallbackUrl` url завершения
    /// сценария прохождения 3DS
    ///
    /// - Returns: URL
    private(set) lazy var confirmation3DSTerminationV2URL: URL = {
        self.urlDomain.appendingPathComponent(self.apiPathV2).appendingPathComponent("Submit3DSAuthorizationV2")
    }()

    /// Во время прохождения 3DS v2 (ACS) WKNavigationDelegate отслеживает редиректы формы 3DS,
    /// этот url считается конечным в сценарии прохождения 3DS
    ///
    /// - Returns: URL
    private(set) lazy var complete3DSMethodV2URL: URL = {
        self.urlDomain.appendingPathComponent(self.apiPathV2).appendingPathComponent("Complete3DSMethodv2")
    }()

    private func setDefaultHTTPHeaders(for request: inout URLRequest) {
        request.setValue("application/x-www-form-urlencoded; charset=utf-8; gzip,deflate;", forHTTPHeaderField: "Content-Type")
        request.setValue("text/html,application/xhtml+xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "xx"
        let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "x"

        let userAgentString = "\(deviceInfo.model)/\(deviceInfo.systemName)/\(deviceInfo.systemVersion)/TinkoffAcquiringSDK/\(version)(\(build))"
        request.setValue(userAgentString, forHTTPHeaderField: "User-Agent")
    }

    func createConfirmation3DSRequest(requestData: Confirmation3DSData) throws -> URLRequest {
        guard let requestURL = URL(string: requestData.acsUrl) else {
            throw NSError(domain: NSLocalizedString("TinkoffAcquiring.requestConfirmation.create.false", tableName: nil, bundle: .coreResources,
                                                    comment: "Can't create confirmation request"), code: 1, userInfo: try requestData.encode2JSONObject())
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        setDefaultHTTPHeaders(for: &request)
        //
        var parameters = try requestData.encode2JSONObject()
        parameters.removeValue(forKey: "ACSUrl")
        parameters.updateValue(confirmation3DSTerminationURL.absoluteString, forKey: "TermUrl")

        logger?.log("Start 3DS Confirmation WebView POST request: \(request.description), with paramaters: \(parameters)")

        let paramsString = generateBodyParamsString(using: parameters)

        request.httpBody = paramsString.data(using: .utf8)

        return request
    }
    
    private func generateBodyParamsString(using parameters: JSONObject) -> String {
        let allowedCharacters = CharacterSet(charactersIn: " \"#%/:<>?@[\\]^`{|}+=").inverted
        let bodyParamsString = parameters.compactMap { (item) -> String? in
            let paramValue = "\(item.value)".addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? item.value
            return "\(item.key)=\(paramValue)"
        }.joined(separator: "&")
        
        return bodyParamsString
    }

    /// Для прохождения 3DS v2 (ACS) нужно подготовить URLRequest для загрузки формы подтверждения в webView
    ///
    /// - Parameters:
    ///   - requestData: параметры `Confirmation3DSDataACS`
    ///   - messageVersion: точная версия 3DS в виде строки.
    /// - Returns:  throws `URLRequest`
    func createConfirmation3DSRequestACS(requestData: Confirmation3DSDataACS, messageVersion: String) throws -> URLRequest {
        guard let requestURL = URL(string: requestData.acsUrl) else {
            throw NSError(domain: NSLocalizedString("TinkoffAcquiring.requestConfirmation.create.false", tableName: nil, bundle: .coreResources,
                                                    comment: "Can't create confirmation request"), code: 1, userInfo: try requestData.encode2JSONObject())
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        setDefaultHTTPHeaders(for: &request)
        //
        let parameterValue = "{\"threeDSServerTransID\":\"\(requestData.tdsServerTransId)\",\"acsTransID\":\"\(requestData.acsTransId)\",\"messageVersion\":\"\(messageVersion)\",\"challengeWindowSize\":\"05\",\"messageType\":\"CReq\"}"
        let encodedString = Data(parameterValue.utf8).base64EncodedString()
        
        /// Remove padding
        /// About padding you can read here: https://www.pixelstech.net/article/1457585550-How-does-Base64-work
        let noPaddingEncodedString = encodedString.replacingOccurrences(of: "=", with: "")
        
        request.httpBody = Data("creq=\(noPaddingEncodedString)".utf8)

        return request
    }

    /// Для прохождения 3DS v1 нужно подготовить URLRequest для загрузки формы подтверждения в webView
    ///
    /// - Parameters:
    ///   - requestData: параметры `Checking3DSURLData`
    /// - Returns:  throws `URLRequest`
    func createChecking3DSURL(requestData: Checking3DSURLData) throws -> URLRequest {
        guard let requestURL = URL(string: requestData.threeDSMethodURL) else {
            throw NSError(domain: NSLocalizedString("TinkoffAcquiring.requestConfirmation.create.false", tableName: nil, bundle: .coreResources,
                                                    comment: "Can't create request"), code: 1, userInfo: nil)
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        setDefaultHTTPHeaders(for: &request)
        //
        let parameterValue = "{\"threeDSServerTransID\":\"\(requestData.tdsServerTransID)\",\"threeDSMethodNotificationURL\":\"\(requestData.notificationURL)\"}"
        let encodedString = Data(parameterValue.utf8).base64EncodedString()
        
        /// Remove padding
        /// About padding you can read here: https://www.pixelstech.net/article/1457585550-How-does-Base64-work
        let noPaddingEncodedString = encodedString.replacingOccurrences(of: "=", with: "")
        
        request.httpBody = try JSONSerialization.data(withJSONObject: ["threeDSMethodData": Data(base64Encoded: noPaddingEncodedString)], options: [.sortedKeys])

        return request
    }

    func myIpAddress() -> String? {
        return IPAddressProvider.my()
    }

    func send<Operation: RequestOperation, Response: ResponseOperation>(operation: Operation, responseDelegate: NetworkTransportResponseDelegate? = nil, completionHandler: @escaping (_ results: Result<Response, Error>) -> Void) -> Cancellable {
        let request: URLRequest
        do {
            request = try createRequest(domain: urlDomain.appendingPathComponent(apiPathV2), for: operation)
        } catch {
            completionHandler(.failure(error))
            return EmptyCancellable()
        }

        let responseLoger = logger

        let task = session.dataTask(with: request) { data, response, networkError in
            if let error = networkError {
                responseLoger?.log("🛬 End request: \(request.description), with: \(error.localizedDescription)")
                return completionHandler(.failure(error))
            }

            if let responseData = data, let string = String(data: responseData, encoding: .utf8) {
                responseLoger?.log("🛬 End request: \(request.description), with response data:\n\(string)")
            }

            // HTTPURLResponse
            guard let httpResponse = response as? HTTPURLResponse else {
                return completionHandler(.failure(NSError(domain: "Response should be an HTTPURLResponse", code: 1, userInfo: nil)))
            }

            // httpResponse check  HTTP Status Code `200..<300`
            guard httpResponse.isSuccessful else {
                let error = HTTPResponseError(body: data, response: httpResponse, kind: .errorResponse)
                completionHandler(.failure(error))
                return
            }

            // data is empty
            guard let data = data else {
                let error = HTTPResponseError(body: nil, response: httpResponse, kind: .invalidResponse)
                completionHandler(.failure(error))
                return
            }

            // delegating decode response data
            if let delegate = responseDelegate {
                guard let delegatedResponse = try? delegate.networkTransport(didCompleteRawTaskForRequest: request, withData: data, response: httpResponse, error: networkError) else {
                    let error = HTTPResponseError(body: data, response: httpResponse, kind: .invalidResponse)
                    completionHandler(.failure(error))
                    return
                }

                completionHandler(.success(delegatedResponse as! Response))
                return
            }

            // decode as a default `AcquiringResponse`
            guard let acquiringResponse = try? JSONDecoder().decode(AcquiringResponse.self, from: data) else {
                let error = HTTPResponseError(body: data, response: httpResponse, kind: .invalidResponse)
                completionHandler(.failure(error))
                return
            }

            // data  in `AcquiringResponse` format but `Success = 0;` ( `false` )
            guard acquiringResponse.success else {
                var errorMessage: String = NSLocalizedString("TinkoffAcquiring.response.error.statusFalse", tableName: nil, bundle: .coreResources,
                                                             comment: "Acquiring Error Response 'Success: false'")
                if let message = acquiringResponse.errorMessage {
                    errorMessage = message
                }

                if let details = acquiringResponse.errorDetails, details.isEmpty == false {
                    errorMessage.append(contentsOf: " ")
                    errorMessage.append(contentsOf: details)
                }

                let error = NSError(domain: errorMessage,
                                    code: acquiringResponse.errorCode,
                                    userInfo: try? acquiringResponse.encode2JSONObject())

                completionHandler(.failure(error))
                return
            }

            // decode to `Response`
            if let responseObject: Response = try? JSONDecoder().decode(Response.self, from: data) {
                completionHandler(.success(responseObject))
            } else {
                completionHandler(.failure(HTTPResponseError(body: data, response: httpResponse, kind: .invalidResponse)))
            }
        } // session.dataTask

        task.resume()

        return task
    } // send
    
    // TODO: - привести отправку запросов к единому виду при рефакторинге компонента
    @discardableResult
    func sendCertsConfigRequest<Operation: RequestOperation>(
        operation: Operation,
        completionHandler: @escaping (Result<GetCertsConfigResponse, Error>) -> Void
    ) -> Cancellable  {

        let request: URLRequest
        do {
            request = try createRequest(domain: certsConfigDomain, for: operation)
        } catch {
            completionHandler(.failure(error))
            return EmptyCancellable()
        }

        let responseLoger = logger

        let task = session.dataTask(with: request) { data, response, networkError in
            if let error = networkError {
                responseLoger?.log("🛬 End request: \(request.description), with: \(error.localizedDescription)")
                return completionHandler(.failure(error))
            }

            if let responseData = data, let string = String(data: responseData, encoding: .utf8) {
                responseLoger?.log("🛬 End request: \(request.description), with response data:\n\(string)")
            }

            // HTTPURLResponse
            guard let httpResponse = response as? HTTPURLResponse else {
                return completionHandler(.failure(NSError(domain: "Response should be an HTTPURLResponse", code: 1, userInfo: nil)))
            }

            // httpResponse check  HTTP Status Code `200..<300`
            guard httpResponse.isSuccessful else {
                let error = HTTPResponseError(body: data, response: httpResponse, kind: .errorResponse)
                completionHandler(.failure(error))
                return
            }

            // data is empty
            guard let data = data else {
                let error = HTTPResponseError(body: nil, response: httpResponse, kind: .invalidResponse)
                completionHandler(.failure(error))
                return
            }

            // decode to `Response`
            if let responseObject = try? JSONDecoder.customISO8601Decoding.decode(GetCertsConfigResponse.self, from: data) {
                completionHandler(.success(responseObject))
            } else {
                completionHandler(.failure(HTTPResponseError(body: data, response: httpResponse, kind: .invalidResponse)))
            }
        } // session.dataTask

        task.resume()

        return task
    }
}
