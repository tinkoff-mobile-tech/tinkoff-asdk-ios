//
//  IMainFormTableContentProvider.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 18.04.2023.
//

import UIKit

protocol IMainFormTableContentProvider {
    func tableHeaderView() -> UIView
    func registerCells(in tableView: UITableView)
    func height(for cellType: MainFormCellType, in tableView: UITableView) -> CGFloat

    func dequeueCell(
        from tableView: UITableView,
        at indexPath: IndexPath,
        withType cellType: MainFormCellType
    ) -> UITableViewCell

    func pullableContainerHeight(
        for cellTypes: [MainFormCellType],
        in tableView: UITableView,
        availableSpace: CGFloat
    ) -> CGFloat
}
