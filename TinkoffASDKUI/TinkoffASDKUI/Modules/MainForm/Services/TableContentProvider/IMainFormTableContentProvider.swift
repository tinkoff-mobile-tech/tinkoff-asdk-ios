//
//  IMainFormTableContentProvider.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 18.04.2023.
//

import UIKit

protocol IMainFormTableContentProvider: ITableContentProvider where CellType == MainFormCellType {
    func tableHeaderView() -> UIView
}
