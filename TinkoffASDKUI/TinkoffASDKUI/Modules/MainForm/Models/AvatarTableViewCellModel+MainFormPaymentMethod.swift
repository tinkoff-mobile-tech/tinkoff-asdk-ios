//
//  AvatarTableViewCellModel+MainFormPaymentMethod.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 09.02.2023.
//

import Foundation

extension AvatarTableViewCellModel {
    static func viewModel(from paymentMethod: MainFormPaymentMethod) -> AvatarTableViewCellModel {
        switch paymentMethod {
        case .card:
            return AvatarTableViewCellModel(
                title: "Картой",
                avatarImage: Asset.PaymentCard.cardFrontsideAvatar.image
            )
        case .tinkoffPay:
            return AvatarTableViewCellModel(
                title: "Tinkoff Pay",
                description: "В приложении Тинькофф",
                avatarImage: Asset.TinkoffPay.tinkoffPayAvatar.image
            )
        case .sbp:
            return AvatarTableViewCellModel(
                title: "СБП",
                description: "В приложении любого банка",
                avatarImage: Asset.Sbp.sbpAvatar.image
            )
        }
    }
}
