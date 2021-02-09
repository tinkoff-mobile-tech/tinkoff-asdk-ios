//
//
//  AcquiringAPI.swift
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

final class AcquiringAPI: API {
    private let environment: AcquiringSdkEnvironment
    private let networkClient: NetworkClient
    private let apiCommonParametersProvider: APICommonParametersProvider
    
    init(environment: AcquiringSdkEnvironment,
         networkClient: NetworkClient,
         apiCommonParametersProvider: APICommonParametersProvider) {
        self.environment = environment
        self.networkClient = networkClient
        self.apiCommonParametersProvider = apiCommonParametersProvider
        self.networkClient.requestAdapter = apiCommonParametersProvider
    }
    
    func performRequest(_ request: APIRequest) {
        networkClient.performRequest(request) { response in
            // TODO:
        }
    }
}
