//
//  GetSBPBanksRequest.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 23.12.2022.
//

import Foundation

struct GetSBPBanksRequest: NetworkRequest {
    let baseURL = URL(string: "https://qr.nspk.ru")!
    let path = "proxyapp/c2bmembers.json"
    let httpMethod: HTTPMethod = .get
}
