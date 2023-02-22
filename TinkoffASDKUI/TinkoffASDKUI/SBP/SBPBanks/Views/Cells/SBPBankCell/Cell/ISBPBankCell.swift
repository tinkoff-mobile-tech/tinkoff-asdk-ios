//
//  ISBPBankCell.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 29.12.2022.
//

import UIKit

protocol ISBPBankCell: NSObject {
    var presenter: ISBPBankCellPresenter? { get set }

    func showSkeletonViews()
    func setNameLabel(text: String)
    func setLogo(image: UIImage, animated: Bool)
}
