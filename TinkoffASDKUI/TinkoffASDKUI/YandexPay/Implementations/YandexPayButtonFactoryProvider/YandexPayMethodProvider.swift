//
//  YandexPayMethodProvider.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 30.11.2022.
//

import Foundation
import TinkoffASDKCore

final class YandexPayMethodProvider: IYandexPayMethodProvider {
    enum Error: Swift.Error {
        case methodUnavailable
        case common(error: Swift.Error)
    }

    // MARK: Dependencies

    private let terminalService: IAcquiringTerminalService

    // MARK: Init

    init(terminalService: IAcquiringTerminalService) {
        self.terminalService = terminalService
    }

    // MARK: IYandexPayMethodProvider

    func provideMethod(completion: @escaping (Result<YandexPayMethod, Swift.Error>) -> Void) {
        terminalService.getTerminalPayMethods { result in
            let methodResult = result
                .mapError { Error.common(error: $0) }
                .flatMap(self.yandexPayMethodResult)
                .mapError { $0 as Swift.Error }

            completion(methodResult)
        }
    }

    // MARK: Helpers

    private func yandexPayMethodResult(from payload: GetTerminalPayMethodsPayload) -> Result<YandexPayMethod, Error> {
        for method in payload.terminalInfo.payMethods {
            if case let .yandexPay(yandexPayMethod) = method {
                return .success(yandexPayMethod)
            }
        }

        return .failure(.methodUnavailable)
    }
}
