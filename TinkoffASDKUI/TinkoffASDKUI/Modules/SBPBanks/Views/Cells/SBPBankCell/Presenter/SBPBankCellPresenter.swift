//
//  SBPBankCellPresenter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 29.12.2022.
//

import TinkoffASDKCore
import UIKit

enum SBPBankCellType {
    case bank(SBPBank)
    case bankButton(imageAsset: ImageAsset, name: String)
    case skeleton
    case blank
}

private enum SBPCellImageLoadingStatus {
    case notLoaded
    case loadingInProcess
    case failedPreviousTime
    case repeatLoadingInProcess
    case loaded(UIImage)
}

final class SBPBankCellPresenter: ISBPBankCellPresenter {

    // Dependencies
    weak var cell: ISBPBankCell? {
        didSet {
            setupCell()
        }
    }

    private let cellImageLoader: ICellImageLoader

    // Properties
    let cellType: SBPBankCellType
    let action: VoidBlock

    var bankName: String { bank?.name ?? "" }

    private var bank: SBPBank? {
        switch cellType {
        case let .bank(bank): return bank
        default: return nil
        }
    }

    private var imageLoadingStatus: SBPCellImageLoadingStatus = .notLoaded

    // MARK: - Initialization

    init(cellType: SBPBankCellType, action: @escaping VoidBlock, cellImageLoader: ICellImageLoader) {
        self.cellType = cellType
        self.action = action
        self.cellImageLoader = cellImageLoader
    }
}

// MARK: - Public

extension SBPBankCellPresenter {
    func startLoadingCellImageIfNeeded() {
        switch imageLoadingStatus {
        case .notLoaded:
            loadCellImage()
        case .loadingInProcess:
            break
        case .failedPreviousTime:
            cellSetPlaceholderLogoImage(animated: false)
            loadCellImage()
        case .repeatLoadingInProcess:
            cellSetPlaceholderLogoImage(animated: false)
        case let .loaded(image):
            cell?.setLogo(image: image, animated: false)
        }
    }
}

// MARK: - Private

extension SBPBankCellPresenter {
    private func setupCell() {
        switch cellType {
        case let .bank(bank):
            cell?.setNameLabel(text: bank.name)
            startLoadingCellImageIfNeeded()
        case let .bankButton(imageAsset, name):
            cell?.setLogo(image: imageAsset.image, animated: false)
            cell?.setNameLabel(text: name)
        case .skeleton:
            cell?.showSkeletonViews()
        case .blank:
            cell?.setLogo(image: nil, animated: false)
            cell?.setNameLabel(text: nil)
            cell?.set(selectionStyle: .none)
        }
    }

    private func loadCellImage() {
        guard let logoURL = bank?.logoURL else { return }

        switch imageLoadingStatus {
        case .failedPreviousTime: imageLoadingStatus = .repeatLoadingInProcess
        default: imageLoadingStatus = .loadingInProcess
        }

        cellImageLoader.loadImage(url: logoURL, completion: { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(image):
                self.imageLoadingStatus = .loaded(image)
                self.cell?.setLogo(image: image, animated: true)
            case .failure:
                self.imageLoadingStatus = .failedPreviousTime
                self.cellSetPlaceholderLogoImage(animated: true)
            }
        })
    }

    private func cellSetPlaceholderLogoImage(animated: Bool) {
        cell?.setLogo(image: Asset.Sbp.sbpNoImage.image, animated: animated)
    }
}
