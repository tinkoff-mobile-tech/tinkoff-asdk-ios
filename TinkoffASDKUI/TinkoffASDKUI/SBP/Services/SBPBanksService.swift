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

public protocol SBPBanksService {
    func loadBanks(completion: @escaping (Result<[SBPBank], Error>) -> Void)
    func defaultSelectionBankIndex(banks: [SBPBank]) -> Int?
}

public final class DefaultSBPBanksService: SBPBanksService {
    
    private let coreSDK: AcquiringSdk
    
    public init(coreSDK: AcquiringSdk) {
        self.coreSDK = coreSDK
    }
    
    public func loadBanks(completion: @escaping (Result<[SBPBank], Error>) -> Void) {
        coreSDK.loadSBPBanks { result in
            completion(result)
        }
    }
    
    public func defaultSelectionBankIndex(banks: [SBPBank]) -> Int? {
        return 3
    }
}
