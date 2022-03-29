//
//
//  SBPBankLoader.swift
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
 
protocol SBPBankLoader {
    func loadBanks(completion: @escaping (Result<SBPBankResponse, Swift.Error>) -> Void)
}

final class DefaultSBPBankLoader: SBPBankLoader {
    
    enum Error: Swift.Error {
        case failedToLoadBanksList
    }
    
    func loadBanks(completion: @escaping (Result<SBPBankResponse, Swift.Error>) -> Void) {
        URLSession.shared.dataTask(with: .bankListURL) { data, _, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let data = data else {
                completion(.failure(Error.failedToLoadBanksList))
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(SBPBankResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

private extension URL {
    static var bankListURL: URL {
        return URL(string: "https://qr.nspk.ru/proxyapp/c2bmembers.json")!
    }
}
