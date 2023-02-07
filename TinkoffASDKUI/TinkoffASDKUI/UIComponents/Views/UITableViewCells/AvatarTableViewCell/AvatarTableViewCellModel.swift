//
//  AvatarTableViewCellModel.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 06.02.2023.
//

import Foundation

struct AvatarTableViewCellModel {
    let title: String
    let description: String?
    let avatarImage: UIImage

    init(
        title: String,
        description: String? = nil,
        avatarImage: UIImage
    ) {
        self.title = title
        self.description = description
        self.avatarImage = avatarImage
    }
}
