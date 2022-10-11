//
//
//  GenericTableCell.swift
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

final class GenericTableCell<View>: UITableViewCell, ReusableIdentifier where View: UIView & ConfigurableAndReusable {

    private let innerView = View()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: Self.reusableId)
        contentView.addSubview(innerView)
        innerView.dsl.makeEqualToSuperview()
    }

    override func prepareForReuse() {
        innerView.prepareForReuse()
        super.prepareForReuse()
    }
}

// MARK: - GenericTableCell + Configurable

extension GenericTableCell: Configurable {
    func configure(model: View.ConfigurableModel) {
        innerView.configure(model: model)
    }
}

extension GenericTableCell: Stylable where View: Stylable {

    func apply(style: View.Style) {
        innerView.apply(style: style)
    }
}
