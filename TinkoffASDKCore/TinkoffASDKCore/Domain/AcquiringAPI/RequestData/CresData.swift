//
//  CresData.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 06.10.2022.
//

import Foundation

public struct CresData: Encodable {
    let cres: String

    public init(cres: String) {
        self.cres = cres
    }
}
