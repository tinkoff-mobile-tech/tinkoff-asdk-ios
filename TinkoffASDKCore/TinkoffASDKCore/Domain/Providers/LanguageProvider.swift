//
//  LanguageProvider.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 08.10.2022.
//

import Foundation

protocol ILanguageProvider {
    var language: AcquiringSdkLanguage? { get }
}

final class LanguageProvider: ILanguageProvider {
    let language: AcquiringSdkLanguage?

    init(language: AcquiringSdkLanguage?) {
        self.language = language
    }
}
