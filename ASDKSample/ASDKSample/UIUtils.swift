//
//  UIUtils.swift
//  ASDKSample
//
//  Copyright (c) 2020 Tinkoff Bank
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

protocol NibLoadable: AnyObject {

    static var nib: UINib { get }
}

extension NibLoadable {

    static var nib: UINib {
        return UINib(nibName: nibName, bundle: Bundle(for: self))
    }

    static var nibName: String {
        return String(describing: self)
    }
}

extension NibLoadable where Self: UIView {

    static func loadFromNib() -> Self {
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError()
        }

        return view
    }
}

extension UITableView {

    // register cell
    func registerCells(types: [NibLoadable.Type]) {
        types.forEach { type in
            register(type.nib, forCellReuseIdentifier: type.nibName)
        }
    }

    // register heade and footer view
    func registerHeaderFooter(types: [NibLoadable.Type]) {
        types.forEach { type in
            register(type.nib, forHeaderFooterViewReuseIdentifier: type.nibName)
        }
    }

    func defaultCell() -> UITableViewCell {
        if let cellEmpty = dequeueReusableCell(withIdentifier: "defaultCell") {
            return cellEmpty
        } else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "defaultCell")
            cell.selectionStyle = .none

            return cell
        }
    }
}
