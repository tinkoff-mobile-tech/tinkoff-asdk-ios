//
//  TdsSdkInterface.swift
//  TinkoffASDKCore
//
//  Created by Ivan Glushko on 19.07.2023.
//

import Foundation

/// Какой интерфейс для 3DS App Based транзакции поддерживает девайс
public enum TdsSdkInterface: String, Codable {
    case native = "01"
    case html = "02"
    case both = "03"
}
