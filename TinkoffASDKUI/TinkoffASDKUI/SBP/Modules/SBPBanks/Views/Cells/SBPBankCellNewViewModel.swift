//
//  SBPBankCellNewViewModel.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 22.12.2022.
//

struct SBPBankCellNewViewModel {

    // Properties
    let nameLabelText: String
    let logoURL: URL?
    let imageAsset: ImageAsset?
    let schema: String

    let isSkeleton: Bool

    // MARK: - Initialization

    static var skeletonModel: SBPBankCellNewViewModel {
        SBPBankCellNewViewModel(isSkeleton: true)
    }

    init(nameLabelText: String, logoURL: URL?, schema: String) {
        self.nameLabelText = nameLabelText
        self.logoURL = logoURL
        imageAsset = nil
        self.schema = schema
        isSkeleton = false
    }

    init(nameLabelText: String, imageAsset: ImageAsset) {
        self.nameLabelText = nameLabelText
        logoURL = nil
        self.imageAsset = imageAsset
        schema = ""
        isSkeleton = false
    }

    private init(isSkeleton: Bool) {
        nameLabelText = ""
        logoURL = nil
        imageAsset = nil
        schema = ""
        self.isSkeleton = isSkeleton
    }
}
