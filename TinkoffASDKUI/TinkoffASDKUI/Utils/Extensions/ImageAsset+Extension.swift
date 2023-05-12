//
//  ImageAsset+Extension.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 20.04.2023.
//

extension ImageAsset: Equatable {
    static func == (lhs: ImageAsset, rhs: ImageAsset) -> Bool {
        lhs.image == rhs.image
    }
}
