//
//
//  UITableView+Utils.swift
//
//  Copyright (c) 2021 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

extension UITableView {
    func register(_ cellTypes: UITableViewCell.Type...) {
        cellTypes.forEach {
            register($0, forCellReuseIdentifier: "\($0)")
        }
    }

    func dequeue<Cell: UITableViewCell>(_ type: Cell.Type, for indexPath: IndexPath? = nil) -> Cell {
        let identifier = "\(type)"

        // swiftlint:disable force_cast
        if let indexPath = indexPath {
            return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! Cell
        } else {
            return dequeueReusableCell(withIdentifier: identifier) as! Cell
        }
        // swiftlint:enable force_cast
    }
}
