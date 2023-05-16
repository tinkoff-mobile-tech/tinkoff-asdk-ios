//
//  SBPQrCellType.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 14.03.2023.
//

enum SBPQrCellType: Equatable {
    case textHeader(ITextAndImageHeaderViewOutput)
    case qrImage(IQrImageViewOutput)
    
    static func == (lhs: SBPQrCellType, rhs: SBPQrCellType) -> Bool {
        switch (lhs, rhs) {
        case  (.textHeader, .textHeader): return true
        case (.qrImage, .qrImage): return true
        default: return false
        }
    }
}
