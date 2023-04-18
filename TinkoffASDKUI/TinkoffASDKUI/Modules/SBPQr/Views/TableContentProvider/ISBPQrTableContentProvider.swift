//
//  ISBPQrTableContentProvider.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 18.04.2023.
//

import UIKit

protocol ISBPQrTableContentProvider {
    func registerCells(in tableView: UITableView)
    func height(for cellType: SBPQrCellType, in tableView: UITableView) -> CGFloat

    func dequeueCell(
        from tableView: UITableView,
        at indexPath: IndexPath,
        withType cellType: SBPQrCellType
    ) -> UITableViewCell

    func pullableContainerHeight(
        for cellTypes: [SBPQrCellType],
        in tableView: UITableView,
        availableSpace: CGFloat
    ) -> CGFloat
}
