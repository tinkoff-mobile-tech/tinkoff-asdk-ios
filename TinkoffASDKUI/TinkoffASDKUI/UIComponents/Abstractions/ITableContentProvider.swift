//
//  ITableContentProvider.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 27.04.2023.
//

import UIKit

protocol ITableContentProvider {
    associatedtype CellType

    func registerCells(in tableView: UITableView)
    func height(for cellType: CellType, in tableView: UITableView) -> CGFloat

    func dequeueCell(
        from tableView: UITableView,
        at indexPath: IndexPath,
        withType cellType: CellType
    ) -> UITableViewCell

    func pullableContainerHeight(
        for cellTypes: [CellType],
        in tableView: UITableView,
        availableSpace: CGFloat
    ) -> CGFloat
}
