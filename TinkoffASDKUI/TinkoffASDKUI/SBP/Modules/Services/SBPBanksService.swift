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

struct LoadBanksResult {
    let banks: [SBPBank]
    let selectedIndex: Int?
}

protocol SBPBanksService {
    func loadBanks(completion: @escaping (Result<LoadBanksResult, Error>) -> Void)
}

final class DefaultSBPBanksService: SBPBanksService {
    
    private let coreSDK: AcquiringSdk
    
    init(coreSDK: AcquiringSdk) {
        self.coreSDK = coreSDK
    }
    
    func loadBanks(completion: @escaping (Result<LoadBanksResult, Error>) -> Void) {
        coreSDK.loadSBPBanks { [weak self] result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(response):
                self?.handleTinkoff(banks: response.banks, completion: completion)
            }
        }
    }
}

private extension DefaultSBPBanksService {
    func handleTinkoff(banks: [SBPBank],
                       completion: @escaping (Result<LoadBanksResult, Error>) -> Void) {
        guard let tinkoffIndex = banks.firstIndex(where: { $0.name.contains(String.tinkoffBankName) }) else {
            completion(.success(LoadBanksResult(banks: banks, selectedIndex: nil)))
            return
        }
        
        var resultBanks = banks
        let tinkoffBank = resultBanks.remove(at: tinkoffIndex)
        resultBanks.insert(tinkoffBank, at: 0)
        
        completion(.success(LoadBanksResult(banks: resultBanks, selectedIndex: 0)))
    }
}

private extension String {
    static let tinkoffBankName = "Тинькофф"
}
