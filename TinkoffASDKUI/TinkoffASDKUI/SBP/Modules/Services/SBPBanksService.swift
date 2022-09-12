//
//
//  SBPBanksService.swift
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


import TinkoffASDKCore
import Foundation

protocol SBPBanksService {
    func loadBanks(completion: @escaping (Result<[SBPBank], Error>) -> Void)
    func checkBankAvailabilityAndHandleTinkoff(banks: [SBPBank]) -> (banks: [SBPBank], selectedIndex: Int?)
}

final class DefaultSBPBanksService: SBPBanksService {
    
    private let coreSDK: AcquiringSdk
    private let bundleImageProvider: BundleImageProvider
    private let bankAppAvailabilityChecker: SBPBankAppAvailabilityChecker
    
    init(coreSDK: AcquiringSdk,
         bundleImageProvider: BundleImageProvider,
         bankAppAvailabilityChecker: SBPBankAppAvailabilityChecker) {
        self.coreSDK = coreSDK
        self.bundleImageProvider = bundleImageProvider
        self.bankAppAvailabilityChecker = bankAppAvailabilityChecker
    }
    
    func loadBanks(completion: @escaping (Result<[SBPBank], Error>) -> Void) {
        coreSDK.loadSBPBanks(completion: { result in
            switch result {
            case let .success(result):
                completion(.success(result.banks))
            case let .failure(error):
                completion(.failure(error))
            }
        })
    }
    
    func checkBankAvailabilityAndHandleTinkoff(banks: [SBPBank]) -> (banks: [SBPBank], selectedIndex: Int?) {
        var selectedIndex: Int?
        var resultBanks = banks.filter { bankAppAvailabilityChecker.checkIfBankAppAvailable(bank: $0) }
        
        if let tinkoffIndex = resultBanks.firstIndex(where: { $0.name.contains(String.tinkoffBankName) }) {
            let tinkoff = resultBanks.remove(at: tinkoffIndex)
            resultBanks.insert(tinkoff, at: 0)
            selectedIndex = 0
        } else {
            let tinkoff = SBPBank(name: .tinkoffBankName,
                                  logoURL: buildTinkoffIconUrl(),
                                  schema: .tinkoffScheme)
            if bankAppAvailabilityChecker.checkIfBankAppAvailable(bank: tinkoff) {
                resultBanks.insert(tinkoff, at: 0)
                selectedIndex = 0
            }
        }
        
        return (resultBanks, selectedIndex)
    }
    
    func buildTinkoffIconUrl() -> URL? {
        bundleImageProvider.urlForImage(named: .tinkoffLogoName,
                                        imageExtension: .tinkoffLogoExtension)
    }
}

private extension String {
    static let tinkoffBankName = "Тинькофф"
    static let tinkoffScheme = "tinkoffbank"
    static let tinkoffLogoName = "tinkoff_40"
    static let tinkoffLogoExtension = "png"
}
