//
//  SBPQrTableContentProvider.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 18.04.2023.
//

import UIKit

final class SBPQrTableContentProvider: ISBPQrTableContentProvider {
    // MARK: Mirror Views

    private lazy var textHeaderMirror = TextAndImageHeaderView()

    // MARK: ISBPQrTableContentProvider

    func registerCells(in tableView: UITableView) {
        tableView.register(TextAndImageHeaderTableCell.self, QrImageTableCell.self)
    }

    func dequeueCell(
        from tableView: UITableView,
        at indexPath: IndexPath,
        withType cellType: SBPQrCellType
    ) -> UITableViewCell {
        switch cellType {
        case let .textHeader(presenter):
            let cell = tableView.dequeue(cellType: TextAndImageHeaderTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = presenter
            cell.insets = insets(for: cellType)
            return cell
        case let .qrImage(presenter):
            let cell = tableView.dequeue(cellType: QrImageTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = presenter
            cell.insets = insets(for: cellType)
            return cell
        }
    }

    func pullableContainerHeight(
        for cellTypes: [SBPQrCellType],
        in tableView: UITableView,
        availableSpace: CGFloat
    ) -> CGFloat {
        cellTypes.reduce(.zero) { partialResult, cellType in
            partialResult + height(for: cellType, in: tableView)
        }
    }

    func height(for cellType: SBPQrCellType, in tableView: UITableView) -> CGFloat {
        let contentHeight: CGFloat = {
            switch cellType {
            case let .textHeader(presenter):
                let presenterCopy = presenter.copy()
                textHeaderMirror.presenter = presenterCopy
                return calculateHeight(for: textHeaderMirror, in: tableView, using: .textHeaderInsets)
            case .qrImage:
                return QrImageView.Constants.minimalHeight
            }
        }()

        return contentHeight + insets(for: cellType).vertical
    }

    // MARK: Helpers

    private func insets(for cellType: SBPQrCellType) -> UIEdgeInsets {
        switch cellType {
        case .textHeader:
            return .textHeaderInsets
        case .qrImage:
            return .qrImageInsets
        }
    }

    private func calculateHeight(
        for view: UIView,
        in tableView: UITableView,
        using insets: UIEdgeInsets
    ) -> CGFloat {
        view.systemLayoutSizeFitting(
            CGSize(
                width: tableView.bounds.width - insets.horizontal,
                height: UIView.layoutFittingCompressedSize.height
            ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
    }
}

// MARK: - Constants

private extension UIEdgeInsets {
    static let textHeaderInsets = UIEdgeInsets(vertical: 10, horizontal: 16)
    static let qrImageInsets = UIEdgeInsets(vertical: 10, horizontal: 16)
}
