//
//  UITableView+Ext.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 22.12.2022.
//

extension UITableView {
    func register<T: UITableViewCell>(cellType: T.Type) {
        register(cellType, forCellReuseIdentifier: cellType.identifier)
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
