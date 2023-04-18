//
//  IRecurrentPaymentTableContentProvider.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 18.04.2023.
//

import UIKit

protocol IRecurrentPaymentTableContentProvider {
    func registerCells(in tableView: UITableView)
    func height(for cellType: RecurrentPaymentCellType, in tableView: UITableView) -> CGFloat

    func dequeueCell(
        from tableView: UITableView,
        at indexPath: IndexPath,
        withType cellType: RecurrentPaymentCellType
    ) -> UITableViewCell

    func pullableContainerHeight(
        for cellTypes: [RecurrentPaymentCellType],
        in tableView: UITableView,
        availableSpace: CGFloat
    ) -> CGFloat
}
