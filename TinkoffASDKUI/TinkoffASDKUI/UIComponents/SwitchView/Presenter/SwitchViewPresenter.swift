//
//  SwitchViewPresenter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 23.01.2023.
//

typealias SwitchViewPresenterActionBlock = (Bool) -> Void

final class SwitchViewPresenter: ISwitchViewOutput {

    // MARK: Dependencies

    weak var view: ISwitchViewInput? {
        didSet {
            setupView()
        }
    }

    // MARK: Properties

    private let title: String
    private(set) var isOn: Bool
    private let actionBlock: SwitchViewPresenterActionBlock?

    // MARK: Initialization

    init(title: String, isOn: Bool = false, actionBlock: SwitchViewPresenterActionBlock? = nil) {
        self.title = title
        self.isOn = isOn
        self.actionBlock = actionBlock
    }
}

// MARK: - ISwitchViewOutput

extension SwitchViewPresenter {
    func switchButtonValueChanged(to isOn: Bool) {
        guard isOn != self.isOn else { return }

        self.isOn = isOn
        actionBlock?(isOn)
    }
}

// MARK: - Private

extension SwitchViewPresenter {
    private func setupView() {
        view?.setNameLabel(text: title)
        view?.setSwitchButtonState(isOn: isOn)
    }
}
