// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum AcquiringPayment {
    internal enum Button {
      /// Выбрать другую карту
      internal static let chooseCard = L10n.tr("Localizable", "AcquiringPayment.button.chooseCard", fallback: #"Выбрать другую карту"#)
    }
  }
  internal enum CardList {
    /// Карты для оплаты
    internal static let title = L10n.tr("Localizable", "CardList.title", fallback: #"Карты для оплаты"#)
    internal enum Alert {
      internal enum Action {
        /// Отмена
        internal static let cancel = L10n.tr("Localizable", "CardList.alert.action.cancel", fallback: #"Отмена"#)
        /// Удалить
        internal static let delete = L10n.tr("Localizable", "CardList.alert.action.delete", fallback: #"Удалить"#)
      }
      internal enum Message {
        /// Вы уверены, что хотите удалить карту %@?
        internal static func deleteCard(_ p1: Any) -> String {
          return L10n.tr("Localizable", "CardList.alert.message.deleteCard", String(describing: p1), fallback: #"Вы уверены, что хотите удалить карту %@?"#)
        }
      }
      internal enum Title {
        /// Удаление карты
        internal static let deleteCard = L10n.tr("Localizable", "CardList.alert.title.deleteCard", fallback: #"Удаление карты"#)
      }
    }
    internal enum Button {
      /// Добавить новую карту
      internal static let addNewCard = L10n.tr("Localizable", "CardList.button.addNewCard", fallback: #"Добавить новую карту"#)
    }
    internal enum Status {
      /// У вас нет сохраненных карт
      internal static let noCards = L10n.tr("Localizable", "CardList.status.noCards", fallback: #"У вас нет сохраненных карт"#)
    }
  }
  internal enum Sbp {
    internal enum BanksList {
      internal enum Button {
        /// Продолжить
        internal static let title = L10n.tr("Localizable", "SBP.BanksList.Button.Title", fallback: #"Продолжить"#)
      }
      internal enum Header {
        /// Мы откроем приложение этого банка для подтверждения оплаты
        internal static let subtitle = L10n.tr("Localizable", "SBP.BanksList.Header.Subtitle", fallback: #"Мы откроем приложение этого банка для подтверждения оплаты"#)
        /// Выберите банк
        internal static let title = L10n.tr("Localizable", "SBP.BanksList.Header.Title", fallback: #"Выберите банк"#)
      }
    }
    internal enum EmptyBanks {
      /// Для оплаты через СБП необходимо иметь установленными банковские приложения
      internal static let description = L10n.tr("Localizable", "SBP.EmptyBanks.Description", fallback: #"Для оплаты через СБП необходимо иметь установленными банковские приложения"#)
      /// Не найдено ни одного банковского приложения
      internal static let title = L10n.tr("Localizable", "SBP.EmptyBanks.Title", fallback: #"Не найдено ни одного банковского приложения"#)
      internal enum ConfirmationButton {
        /// Понятно
        internal static let title = L10n.tr("Localizable", "SBP.EmptyBanks.ConfirmationButton.Title", fallback: #"Понятно"#)
      }
      internal enum InformationButton {
        /// Информация на сайте СБП
        internal static let title = L10n.tr("Localizable", "SBP.EmptyBanks.InformationButton.Title", fallback: #"Информация на сайте СБП"#)
      }
    }
    internal enum Error {
      /// Попробуйте еще раз
      internal static let description = L10n.tr("Localizable", "SBP.Error.Description", fallback: #"Попробуйте еще раз"#)
      /// Не удалось выполнить оплату через СБП
      internal static let title = L10n.tr("Localizable", "SBP.Error.Title", fallback: #"Не удалось выполнить оплату через СБП"#)
    }
    internal enum LoadingStatus {
      /// Ожидаем подтверждения платежа
      internal static let title = L10n.tr("Localizable", "SBP.LoadingStatus.Title", fallback: #"Ожидаем подтверждения платежа"#)
    }
    internal enum OpenApplication {
      /// Не удалось открыть приложение
      internal static let error = L10n.tr("Localizable", "SBP.OpenApplication.Error", fallback: #"Не удалось открыть приложение"#)
    }
  }
  internal enum Tp {
    internal enum Error {
      /// Попробуйте еще раз
      internal static let description = L10n.tr("Localizable", "TP.Error.Description", fallback: #"Попробуйте еще раз"#)
      /// Не удалось выполнить оплату через Tinkoff Pay
      internal static let title = L10n.tr("Localizable", "TP.Error.Title", fallback: #"Не удалось выполнить оплату через Tinkoff Pay"#)
    }
    internal enum LoadingStatus {
      /// Ожидаем подтверждения платежа
      internal static let title = L10n.tr("Localizable", "TP.LoadingStatus.Title", fallback: #"Ожидаем подтверждения платежа"#)
    }
    internal enum NoTinkoffBankApp {
      /// Скачайте приложение или выберите другой способ оплаты
      internal static let description = L10n.tr("Localizable", "TP.NoTinkoffBankApp.Description", fallback: #"Скачайте приложение или выберите другой способ оплаты"#)
      /// У вас не установлено Tinkoff
      internal static let title = L10n.tr("Localizable", "TP.NoTinkoffBankApp.Title", fallback: #"У вас не установлено Tinkoff"#)
      internal enum Button {
        /// Установить
        internal static let install = L10n.tr("Localizable", "TP.NoTinkoffBankApp.Button.Install", fallback: #"Установить"#)
        /// Отменить
        internal static let сancel = L10n.tr("Localizable", "TP.NoTinkoffBankApp.Button.Сancel", fallback: #"Отменить"#)
      }
    }
  }
  internal enum TinkoffAcquiring {
    internal enum Alert {
      internal enum Message {
        /// Операция отменена
        internal static let addingCardCancel = L10n.tr("Localizable", "TinkoffAcquiring.alert.message.addingCardCancel", fallback: #"Операция отменена"#)
      }
      internal enum Title {
        /// Добавление карты
        internal static let addingCard = L10n.tr("Localizable", "TinkoffAcquiring.alert.title.addingCard", fallback: #"Добавление карты"#)
        /// Карта добавлена
        internal static let cardSuccessAdded = L10n.tr("Localizable", "TinkoffAcquiring.alert.title.cardSuccessAdded", fallback: #"Карта добавлена"#)
        /// Ошибка
        internal static let error = L10n.tr("Localizable", "TinkoffAcquiring.alert.title.error", fallback: #"Ошибка"#)
      }
    }
    internal enum Button {
      /// Добавить
      internal static let addCard = L10n.tr("Localizable", "TinkoffAcquiring.button.addCard", fallback: #"Добавить"#)
      /// Отмена
      internal static let cancel = L10n.tr("Localizable", "TinkoffAcquiring.button.cancel", fallback: #"Отмена"#)
      /// Закрыть
      internal static let close = L10n.tr("Localizable", "TinkoffAcquiring.button.close", fallback: #"Закрыть"#)
      /// Подтвердить
      internal static let confirm = L10n.tr("Localizable", "TinkoffAcquiring.button.confirm", fallback: #"Подтвердить"#)
      /// Удалить
      internal static let delete = L10n.tr("Localizable", "TinkoffAcquiring.button.delete", fallback: #"Удалить"#)
      /// Ok
      internal static let ok = L10n.tr("Localizable", "TinkoffAcquiring.button.ok", fallback: #"Ok"#)
      /// Оплатить через 
      internal static let payBy = L10n.tr("Localizable", "TinkoffAcquiring.button.payBy", fallback: #"Оплатить через "#)
      /// Оплатить по карте
      internal static let payByCard = L10n.tr("Localizable", "TinkoffAcquiring.button.payByCard", fallback: #"Оплатить по карте"#)
      /// QR-код
      internal static let qrcode = L10n.tr("Localizable", "TinkoffAcquiring.button.qrcode", fallback: #"QR-код"#)
      /// Обновить
      internal static let update = L10n.tr("Localizable", "TinkoffAcquiring.button.update", fallback: #"Обновить"#)
    }
    internal enum Error {
      /// укажите сумму с точностью до копеек
      internal static let loopAmount = L10n.tr("Localizable", "TinkoffAcquiring.error.loopAmount", fallback: #"укажите сумму с точностью до копеек"#)
    }
    internal enum Hint {
      /// сумма с точностью до копеек
      internal static let loopAmount = L10n.tr("Localizable", "TinkoffAcquiring.hint.loopAmount", fallback: #"сумма с точностью до копеек"#)
    }
    internal enum Placeholder {
      /// Номер карты
      internal static let cardNumber = L10n.tr("Localizable", "TinkoffAcquiring.placeholder.cardNumber", fallback: #"Номер карты"#)
      /// Например 0,89
      internal static let loopAmount = L10n.tr("Localizable", "TinkoffAcquiring.placeholder.loopAmount", fallback: #"Например 0,89"#)
      /// Отправить квитанцию по адресу
      internal static let sendReceiptToEmail = L10n.tr("Localizable", "TinkoffAcquiring.placeholder.sendReceiptToEmail", fallback: #"Отправить квитанцию по адресу"#)
    }
    internal enum Text {
      /// Добавить карту
      internal static let addcard = L10n.tr("Localizable", "TinkoffAcquiring.text.addcard", fallback: #"Добавить карту"#)
      /// Добавить новую карту
      internal static let addNewCard = L10n.tr("Localizable", "TinkoffAcquiring.text.addNewCard", fallback: #"Добавить новую карту"#)
      /// Для подтверждения операции мы списали и вернули небольшую сумму (до 1,99 руб.)
      /// Пожалуйста, укажите ее с точностью до копеек.
      internal static let loopConfirmation = L10n.tr("Localizable", "TinkoffAcquiring.text.loopConfirmation", fallback: #"Для подтверждения операции мы списали и вернули небольшую сумму (до 1,99 руб.)\nПожалуйста, укажите ее с точностью до копеек."#)
      /// или
      internal static let or = L10n.tr("Localizable", "TinkoffAcquiring.text.or", fallback: #"или"#)
      internal enum Status {
        /// Сохраненных карт нет
        internal static let cardListEmpty = L10n.tr("Localizable", "TinkoffAcquiring.text.status.cardListEmpty", fallback: #"Сохраненных карт нет"#)
        /// Загрузка ...
        internal static let loading = L10n.tr("Localizable", "TinkoffAcquiring.text.status.loading", fallback: #"Загрузка ..."#)
        /// Выбор источника оплаты
        internal static let selectingPaymentSource = L10n.tr("Localizable", "TinkoffAcquiring.text.status.selectingPaymentSource", fallback: #"Выбор источника оплаты"#)
        /// Инициалихация платежа
        internal static let waitingInitPayment = L10n.tr("Localizable", "TinkoffAcquiring.text.status.waitingInitPayment", fallback: #"Инициалихация платежа"#)
        /// Ожидание оплаты
        internal static let waitingPayment = L10n.tr("Localizable", "TinkoffAcquiring.text.status.waitingPayment", fallback: #"Ожидание оплаты"#)
        internal enum Error {
          /// Неверный формат электронной почты
          internal static let email = L10n.tr("Localizable", "TinkoffAcquiring.text.status.error.email", fallback: #"Неверный формат электронной почты"#)
          /// Введите email
          internal static let emailEmpty = L10n.tr("Localizable", "TinkoffAcquiring.text.status.error.emailEmpty", fallback: #"Введите email"#)
        }
      }
    }
    internal enum Threeds {
      /// Подтверждение
      internal static let acceptAuth = L10n.tr("Localizable", "TinkoffAcquiring.threeds.acceptAuth", fallback: #"Подтверждение"#)
      /// Отменить
      internal static let cancelAuth = L10n.tr("Localizable", "TinkoffAcquiring.threeds.cancelAuth", fallback: #"Отменить"#)
      internal enum Error {
        /// Платежная система не поддерживается
        internal static let invalidPaymentSystem = L10n.tr("Localizable", "TinkoffAcquiring.threeds.error.invalidPaymentSystem", fallback: #"Платежная система не поддерживается"#)
        /// Превышено маскимальное время прохождения 3DS
        internal static let timeout = L10n.tr("Localizable", "TinkoffAcquiring.threeds.error.timeout", fallback: #"Превышено маскимальное время прохождения 3DS"#)
        /// Не удалось обновить сертификаты
        internal static let updatingCertsError = L10n.tr("Localizable", "TinkoffAcquiring.threeds.error.updatingCertsError", fallback: #"Не удалось обновить сертификаты"#)
      }
    }
    internal enum Unknown {
      internal enum Error {
        /// Неизвесная ошибка.
        /// Попробуйте поворить операцию.
        internal static let status = L10n.tr("Localizable", "TinkoffAcquiring.unknown.error.status", fallback: #"Неизвесная ошибка.\nПопробуйте поворить операцию."#)
      }
      internal enum Response {
        /// *  Localizable.strings
        ///  *  TinkoffASDKUI
        ///  *
        ///  *  Copyright (c) 2020 Tinkoff Bank
        ///  *
        ///  *  Licensed under the Apache License, Version 2.0 (the "License");
        ///  *  you may not use this file except in compliance with the License.
        ///  *  You may obtain a copy of the License at
        ///  *
        ///  *   http://www.apache.org/licenses/LICENSE-2.0
        ///  *
        ///  *  Unless required by applicable law or agreed to in writing, software
        ///  *  distributed under the License is distributed on an "AS IS" BASIS,
        ///  *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        ///  *  See the License for the specific language governing permissions and
        ///  *  limitations under the License.
        internal static let status = L10n.tr("Localizable", "TinkoffAcquiring.unknown.response.status", fallback: #"Неизвестный статус платежа"#)
      }
    }
    internal enum View {
      internal enum Title {
        /// Подтверждение
        internal static let confimration = L10n.tr("Localizable", "TinkoffAcquiring.view.title.confimration", fallback: #"Подтверждение"#)
        /// Оплата
        internal static let pay = L10n.tr("Localizable", "TinkoffAcquiring.view.title.pay", fallback: #"Оплата"#)
        /// Оплата по QR-коду
        internal static let payQRCode = L10n.tr("Localizable", "TinkoffAcquiring.view.title.payQRCode", fallback: #"Оплата по QR-коду"#)
        /// Сохраненные карты
        internal static let savedCards = L10n.tr("Localizable", "TinkoffAcquiring.view.title.savedCards", fallback: #"Сохраненные карты"#)
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
