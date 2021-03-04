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
        case incorrectThreeDSMethodURL(String)
    }
    
    let threeDSURLBuilder: ThreeDSURLBuilder
    
    init(threeDSURLBuilder: ThreeDSURLBuilder) {
        self.threeDSURLBuilder = threeDSURLBuilder
    }
    
    func build3DSCheckURLRequest(requestData: Checking3DSURLData) throws -> URLRequest {
        guard let check3DSMethodURL = URL(string: requestData.threeDSMethodURL) else {
            throw Error.incorrectThreeDSMethodURL(requestData.threeDSMethodURL)
        }
        
        var request = URLRequest(url: check3DSMethodURL)
        request.httpMethod = HTTPMethod.post.rawValue
        
        let threeDSMethodNotificationURL = (try? threeDSURLBuilder.buildURL(type: .threeDSCheckNotificationURL).absoluteString) ?? ""
        let threeDSMethodJson = ["threeDSServerTransID": requestData.tdsServerTransID,
                                 "threeDSMethodNotificationURL": threeDSMethodNotificationURL]
        let threeDSMethodData = try JSONSerialization.data(withJSONObject: threeDSMethodJson,
                                                           options: .sortedKeys).base64EncodedString()
        
        request = try JSONEncoding().encode(request,
                                            parameters: ["threeDSMethodData": threeDSMethodData])
        return request
    }
}
