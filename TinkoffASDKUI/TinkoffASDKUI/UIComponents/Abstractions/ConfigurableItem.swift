//
//  ConfigurableItem.swift
//  popup
//
//  Created by Ivan Glushko on 23.11.2022.
//

import Foundation

protocol ConfigurableItem {
    associatedtype Configuration
    var configuration: Configuration { get }
    func configure(with: Configuration)
}
