//
//  IYandexPayMethodProvider.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.12.2022.
//

import Foundation
import TinkoffASDKCore

protocol IYandexPayMethodProvider {
    func provideMethod(completion: @escaping (Result<YandexPayMethod, Error>) -> Void)
}
