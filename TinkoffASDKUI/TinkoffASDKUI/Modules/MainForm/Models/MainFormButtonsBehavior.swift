//
//  MainFormButtonsBehavior.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 20.03.2023.
//

import Foundation

/// Сущность, определяющая поведение кнопок в заглушках `CommonSheet` на главной платежной форме
struct MainFormButtonsBehavior {
    /// Действие, которое необходимо выполнить по нажатии на кнопку
    enum ButtonAction {
        /// Необходимо полностью закрыть платежную форму
        case closeForm
        /// Необходимо скрыть заглушку и отобразить контент платежной формы
        case showContent
    }

    /// Действие, которое необходимо выполнить по нажатии на кнопку со стилем `Primary`
    var primaryButton: ButtonAction = .closeForm
    /// Действие, которое необходимо выполнить по нажатии на кнопку со стилем `Secondary`
    var secondaryButton: ButtonAction = .closeForm
}

extension MainFormButtonsBehavior {
    /// Нажатие на любую кнопку будет приводить к закрытию платежной формы
    static var closeForm: MainFormButtonsBehavior {
        MainFormButtonsBehavior()
    }

    /// Нажатие на любую кнопку будет приводить к скрытию заглушки и отображению контента платежной формы
    static var showContent: MainFormButtonsBehavior {
        MainFormButtonsBehavior(primaryButton: .showContent, secondaryButton: .showContent)
    }
}
