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
                title: Loc.CommonSheet.PaymentForm.byCardTitle,
                avatarImage: Asset.PaymentCard.cardFrontsideAvatar.image
            )
        case .tinkoffPay:
            return AvatarTableViewCellModel(
                title: Loc.CommonSheet.PaymentForm.tinkoffPayTitle,
                description: Loc.CommonSheet.PaymentForm.tinkoffPayDescription,
                avatarImage: Asset.TinkoffPay.tinkoffPayAvatar.image
            )
        case .sbp:
            return AvatarTableViewCellModel(
                title: Loc.CommonSheet.PaymentForm.sbpTitle,
                description: Loc.CommonSheet.PaymentForm.sbpDescription,
                avatarImage: Asset.Sbp.sbpAvatar.image
            )
        }
    }
}
