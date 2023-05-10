//
//  RecurrentPaymentTableContentProvider.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 18.04.2023.
//

import UIKit

final class RecurrentPaymentTableContentProvider: IRecurrentPaymentTableContentProvider {
    // MARK: IRecurrentPaymentTableContentProvider

    func registerCells(in tableView: UITableView) {
        tableView.register(SavedCardTableCell.self, PayButtonTableCell.self)
    }

    func dequeueCell(
        from tableView: UITableView,
        at indexPath: IndexPath,
        withType cellType: RecurrentPaymentCellType
    ) -> UITableViewCell {
        switch cellType {
        case let .savedCard(presenter):
            let cell = tableView.dequeue(cellType: SavedCardTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = presenter
            cell.insets = insets(for: cellType)
            return cell
        case let .payButton(presenter):
            let cell = tableView.dequeue(cellType: PayButtonTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = presenter
            cell.insets = insets(for: cellType)
            return cell
        }
    }

    func pullableContainerHeight(
        for cellTypes: [RecurrentPaymentCellType],
        in tableView: UITableView,
        availableSpace: CGFloat
    ) -> CGFloat {
        let contentHeight: CGFloat = cellTypes.reduce(.zero) { $0 + height(for: $1, in: tableView) }
        return min(contentHeight, availableSpace)
    }

    func height(for cellType: RecurrentPaymentCellType, in tableView: UITableView) -> CGFloat {
        let contentHeight: CGFloat = {
            switch cellType {
            case .savedCard:
                return SavedCardView.Constants.minimalHeight
            case .payButton:
                return PayButtonView.Constants.minimalHeight
            }
        }()

        return contentHeight + insets(for: cellType).vertical
    }

    // MARK: Helpers

    private func insets(for cellType: RecurrentPaymentCellType) -> UIEdgeInsets {
        switch cellType {
        case .savedCard:
            return .savedCardInsets
        case .payButton:
            return .payButtonInsets
        }
    }
}

// MARK: - Constants

private extension UIEdgeInsets {
    static let savedCardInsets = UIEdgeInsets(top: 8, left: 16, bottom: 20, right: 16)
    static let payButtonInsets = UIEdgeInsets(top: 8, left: 16, bottom: 24, right: 16)
}
