//
//  Identifiable.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 22.12.2022.
//

protocol Identifiable {
    static var identifier: String { get }
}

extension Identifiable {
    static var identifier: String {
        String(describing: self)
    }
}

extension UITableViewCell: Identifiable {}
