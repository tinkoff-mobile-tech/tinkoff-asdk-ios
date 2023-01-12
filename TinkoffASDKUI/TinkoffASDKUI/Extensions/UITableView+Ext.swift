//
//  UITableView+Ext.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 22.12.2022.
//

import UIKit

extension UITableView {
    func register(_ cellTypes: UITableViewCell.Type...) {
        cellTypes.forEach { register($0, forCellReuseIdentifier: $0.identifier) }
    }

    func dequeue<T: UITableViewCell>(cellType: T.Type, indexPath: IndexPath? = nil) -> T {
        let reusableCell: UITableViewCell?

        if let indexPath = indexPath {
            reusableCell = dequeueReusableCell(withIdentifier: cellType.identifier, for: indexPath)
        } else {
            reusableCell = dequeueReusableCell(withIdentifier: cellType.identifier)
        }

        guard let reusableCell = reusableCell as? T else {
            fatalError("Can't reuse cell: \(cellType.identifier)")
        }

        return reusableCell
    }
}
