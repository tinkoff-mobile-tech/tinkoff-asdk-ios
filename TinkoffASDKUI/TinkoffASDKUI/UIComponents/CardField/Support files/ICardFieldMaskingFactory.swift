//
//  ICardFieldMaskingFactory.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 03.02.2023.
//

protocol ICardFieldMaskingFactory {

    /// Готовит делегат текстфилда
    /// - Parameters:
    ///   - fieldType: тип текст филда
    ///   - listener: слушатель событий делегата
    /// - Returns: Делегат маскированного текст филда
    func buildMaskingDelegate(for fieldType: CardFieldType, listener: MaskedTextFieldDelegateListener) -> MaskedTextFieldDelegate
}
