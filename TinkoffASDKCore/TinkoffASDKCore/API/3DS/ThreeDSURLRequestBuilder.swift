//
//
//  ThreeDSURLRequestBuilder.swift
//
//  Copyright (c) 2021 Tinkoff Bank
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

final class ThreeDSURLRequestBuilder {
    
    enum Error: Swift.Error {
        case incorrectUrl(String)
    }
    
    let threeDSURLBuilder: ThreeDSURLBuilder
    let deviceInfoProvider: DeviceInfoProvider
    
    init(threeDSURLBuilder: ThreeDSURLBuilder,
         deviceInfoProvider: DeviceInfoProvider) {
        self.threeDSURLBuilder = threeDSURLBuilder
        self.deviceInfoProvider = deviceInfoProvider
    }
    
    func buildConfirmation3DSRequestACS(requestData: Confirmation3DSDataACS,
                                        version: String) throws -> URLRequest {
        guard let url = URL(string: requestData.acsUrl) else {
            throw Error.incorrectUrl(requestData.acsUrl)
        }
        
        let creqJson = [APIConstants.Keys.threeDSServerTransID: requestData.tdsServerTransId,
                        APIConstants.Keys.acsTransID: requestData.acsTransId,
                        APIConstants.Keys.messageVersion: version,
                        APIConstants.Keys.challengeWindowSize: "05",
                        APIConstants.Keys.messageType: "CReq"]
        let creq = try JSONSerialization.data(withJSONObject: creqJson,
                                              options: .sortedKeys).base64EncodedString()
        
        /// Remove padding
        /// About padding you can read here: https://www.pixelstech.net/article/1457585550-How-does-Base64-work
        let noPaddingCreq = creq.replacingOccurrences(of: "=", with: "")
        
        return request(url: url, body: "\(APIConstants.Keys.creq)=\(noPaddingCreq)".data(using: .utf8))
    }
    
    func buildConfirmation3DSRequest(requestData: Confirmation3DSData) throws -> URLRequest {
        guard let url = URL(string: requestData.acsUrl) else {
            throw Error.incorrectUrl(requestData.acsUrl)
        }
        
        // TODO: Log error
        let termUrl = (try? threeDSURLBuilder.buildURL(type: .confirmation3DSTerminationURL).absoluteString) ?? ""
        let parameters = [APIConstants.Keys.paReq: requestData.pareq,
                          APIConstants.Keys.md: requestData.md,
                          APIConstants.Keys.termUrl: termUrl]
        
        let allowedCharacterSet = CharacterSet(charactersIn: " \"#%/:<>?@[\\]^`{|}+=").inverted
        let bodyString = parameters.map {
            "\($0.key)=\("\($0.value)".addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? $0.value)"
        }.joined(separator: "&")
        
        return request(url: url, body: bodyString.data(using: .utf8))
    }
    
    func build3DSCheckURLRequest(requestData: Checking3DSURLData) throws -> URLRequest {
        guard let check3DSMethodURL = URL(string: requestData.threeDSMethodURL) else {
            throw Error.incorrectUrl(requestData.threeDSMethodURL)
        }
        
        // TODO: Log error
        let threeDSMethodNotificationURL = (try? threeDSURLBuilder.buildURL(type: .threeDSCheckNotificationURL).absoluteString) ?? ""
        let threeDSMethodJson = [APIConstants.Keys.threeDSServerTransID: requestData.tdsServerTransID,
                                 APIConstants.Keys.threeDSMethodNotificationURL: threeDSMethodNotificationURL]
        let threeDSMethodData = try JSONSerialization.data(withJSONObject: threeDSMethodJson,
                                                           options: .sortedKeys).base64EncodedString()
        
        return request(url: check3DSMethodURL, body: "\(APIConstants.Keys.threeDSMethodData)=\(threeDSMethodData)".data(using: .utf8))
    }
}

private extension ThreeDSURLRequestBuilder {
    func request(url: URL, body: Data?) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.httpBody = body
        updateHeader(request: &request)
        return request
    }
    
    
    func updateHeader(request: inout URLRequest) {
        request.setValue("application/x-www-form-urlencoded;", forHTTPHeaderField: "Content-Type")
        request.setValue("text/html,application/xhtml+xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        
        let userAgentString = "\(deviceInfoProvider.model)/\(deviceInfoProvider.systemName)/\(deviceInfoProvider.systemVersion)/TinkoffAcquiringSDK"
        request.setValue(userAgentString, forHTTPHeaderField: "User-Agent")
    }
}
