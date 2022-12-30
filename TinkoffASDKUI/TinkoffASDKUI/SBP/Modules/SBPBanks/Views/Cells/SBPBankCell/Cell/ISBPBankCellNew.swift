//
//  ISBPBankCellNew.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 29.12.2022.
//

protocol ISBPBankCellNew: NSObject {
    var presenter: ISBPBankCellNewPresenter? { get set }

    func showSkeletonViews()
    func setNameLabel(text: String)
    func setLogo(image: UIImage, animated: Bool)
}
