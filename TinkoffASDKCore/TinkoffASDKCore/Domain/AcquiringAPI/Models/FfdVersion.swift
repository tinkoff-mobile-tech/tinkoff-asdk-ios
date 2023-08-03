//
//  FfdVersion.swift
//  TinkoffASDKCore
//
//  Created by Никита Васильев on 02.08.2023.
//
// swiftlint:disable identifier_name

import Foundation

public enum FfdVersion: String, Codable {
    /// По умолчанию версия ФФД - 1.05
    case version1_05 = "1.05"
    case version1_2 = "1.2"
}
