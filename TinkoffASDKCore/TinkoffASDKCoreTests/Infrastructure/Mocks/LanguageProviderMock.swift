//
//  LanguageProviderMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 21.07.2023.
//

import Foundation
@testable import TinkoffASDKCore

final class LanguageProviderMock: ILanguageProvider {
    var language: AcquiringSdkLanguage?
}
