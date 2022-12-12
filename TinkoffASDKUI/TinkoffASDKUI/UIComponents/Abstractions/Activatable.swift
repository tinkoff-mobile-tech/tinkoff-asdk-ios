//
//  Activatable.swift
//  popup
//
//  Created by Ivan Glushko on 23.11.2022.
//

import Foundation

protocol Activatable {
    var isActive: Bool { get }

    func activate()
    func deactivate()
}
