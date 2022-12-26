//
//  INetworkDataTask.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 23.12.2022.
//

import Foundation

protocol INetworkDataTask: Cancellable {
    func resume()
}
