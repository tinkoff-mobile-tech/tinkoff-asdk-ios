//
//  MockCardRequisitesValidator.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 30.11.2022.
//

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

import Foundation

final class MockCardRequisitesValidator: ICardRequisitesValidator {

    var validate_validThru_CallCounter = 0
    var validate_validThru_Stub: ((validThruYear: Int, month: Int)) -> Bool = { _ in false }

    func validate(validThruYear: Int, month: Int) -> Bool {
        return validate_validThru_Stub((validThruYear, month))
    }

    // MARK: - validate_InputPAN_Stub

    var validate_inputPAN_CallCounter = 0
    var validate_inputPAN_Stub: (_ inputPAN: String?) -> Bool = { _ in false }

    func validate(inputPAN: String?) -> Bool {
        validate_inputPAN_CallCounter += 1
        return validate_inputPAN_Stub(inputPAN)
    }

    // MARK: - validate_inputCVC

    var validate_inputCVC_CallCounter = 0
    var validate_inputCVC_Stub: (_ inputCVC: String?) -> Bool = { _ in false }

    func validate(inputCVC: String?) -> Bool {
        validate_inputCVC_CallCounter += 1
        return validate_inputCVC_Stub(inputCVC)
    }
}
