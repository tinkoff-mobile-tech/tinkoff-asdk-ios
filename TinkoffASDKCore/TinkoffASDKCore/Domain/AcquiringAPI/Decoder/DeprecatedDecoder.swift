//
//  DeprecatedDecoder.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 09.10.2022.
//

import Foundation

protocol IDeprecatedDecoder {
    func decode<Response: ResponseOperation>(data: Data, with response: HTTPURLResponse?) throws -> Response
}

final class DeprecatedDecoder: IDeprecatedDecoder {
    private let decoder = JSONDecoder()

    func decode<Response: ResponseOperation>(data: Data, with response: HTTPURLResponse?) throws -> Response {
        let response = try response.orThrow(NSError(domain: "Response must exist", code: 1))

        // decode as a default `AcquiringResponse`
        guard let acquiringResponse = try? decoder.decode(AcquiringResponse.self, from: data) else {
            throw HTTPResponseError(body: data, response: response, kind: .invalidResponse)
        }

        // data  in `AcquiringResponse` format but `Success = 0;` ( `false` )
        guard acquiringResponse.success, acquiringResponse.errorCode == 0 else {
            var errorMessage: String = Loc.TinkoffAcquiring.Response.Error.statusFalse

            if let message = acquiringResponse.errorMessage {
                errorMessage = message
            }

            if let details = acquiringResponse.errorDetails, details.isEmpty == false {
                errorMessage.append(contentsOf: " ")
                errorMessage.append(contentsOf: details)
            }

            let error = NSError(
                domain: errorMessage,
                code: acquiringResponse.errorCode,
                userInfo: try? acquiringResponse.encode2JSONObject()
            )

            throw error
        }

        // decode to `Response`
        if let responseObject: Response = try? decoder.decode(Response.self, from: data) {
            return responseObject
        } else {
            throw HTTPResponseError(body: data, response: response, kind: .invalidResponse)
        }
    }
}
