// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Loc {
  internal enum Acquiring {
    internal enum AddNewCard {
      /// Добавить
      internal static let addButton = Loc.tr("Localizable", "Acquiring.AddNewCard.AddButton", fallback: "Добавить")
      /// Закрыть
      internal static let buttonClose = Loc.tr("Localizable", "Acquiring.AddNewCard.ButtonClose", fallback: "Закрыть")
      /// Новая карта
      internal static let screenTitle = Loc.tr("Localizable", "Acquiring.AddNewCard.ScreenTitle", fallback: "Новая карта")
    }
    internal enum CardField {
      /// 123
      internal static let cvvPlaceholder = Loc.tr("Localizable", "Acquiring.CardField.CVVPlaceholder", fallback: "123")
      /// Код
      internal static let cvvTitle = Loc.tr("Localizable", "Acquiring.CardField.CVVTitle", fallback: "Код")
      /// Номер
      internal static let panTitle = Loc.tr("Localizable", "Acquiring.CardField.PanTitle", fallback: "Номер")
      /// 07/30
      internal static let termPlaceholder = Loc.tr("Localizable", "Acquiring.CardField.TermPlaceholder", fallback: "07/30")
      /// Срок
      internal static let termTitle = Loc.tr("Localizable", "Acquiring.CardField.TermTitle", fallback: "Срок")
    }
    internal enum CardList {
      /// Добавить новую
      internal static let addCard = Loc.tr("Localizable", "Acquiring.CardList.AddCard", fallback: "Добавить новую")
      /// Карта %@ добавлена
      internal static func addSnackBar(_ p1: Any) -> String {
        return Loc.tr("Localizable", "Acquiring.CardList.AddSnackBar", String(describing: p1), fallback: "Карта %@ добавлена")
      }
      /// Изменить
      internal static let buttonChange = Loc.tr("Localizable", "Acquiring.CardList.ButtonChange", fallback: "Изменить")
      /// Готово
      internal static let buttonDone = Loc.tr("Localizable", "Acquiring.CardList.ButtonDone", fallback: "Готово")
      /// Удаляем карту
      internal static let deleteSnackBar = Loc.tr("Localizable", "Acquiring.CardList.DeleteSnackBar", fallback: "Удаляем карту")
      /// Ваши карты
      internal static let screenTitle = Loc.tr("Localizable", "Acquiring.CardList.ScreenTitle", fallback: "Ваши карты")
    }
    internal enum Common {
      /// Альфа Банк
      internal static let alfaCardTitle = Loc.tr("Localizable", "Acquiring.Common.AlfaCardTitle", fallback: "Альфа Банк")
      /// Газпром Банк
      internal static let gazpromCardTitle = Loc.tr("Localizable", "Acquiring.Common.GazpromCardTitle", fallback: "Газпром Банк")
      /// Райффайзен Банк
      internal static let raiffeisenCardTitle = Loc.tr("Localizable", "Acquiring.Common.RaiffeisenCardTitle", fallback: "Райффайзен Банк")
      /// СберБанк
      internal static let sberCardTitle = Loc.tr("Localizable", "Acquiring.Common.SberCardTitle", fallback: "СберБанк")
      /// Тинькофф
      internal static let tcsCardTitle = Loc.tr("Localizable", "Acquiring.Common.TcsCardTitle", fallback: "Тинькофф")
      /// Банк ВТБ
      internal static let vtbCardTitle = Loc.tr("Localizable", "Acquiring.Common.VtbCardTitle", fallback: "Банк ВТБ")
    }
    internal enum EmailField {
      /// Электронная почта
      internal static let title = Loc.tr("Localizable", "Acquiring.EmailField.Title", fallback: "Электронная почта")
    }
    internal enum Sbp {
      /// Выбор банка
      internal static let screenTitle = Loc.tr("Localizable", "Acquiring.SBP.ScreenTitle", fallback: "Выбор банка")
    }
    internal enum SBPAllBanks {
      /// Название
      internal static let searchPlaceholder = Loc.tr("Localizable", "Acquiring.SBPAllBanks.SearchPlaceholder", fallback: "Название")
    }
    internal enum SBPBanks {
      /// Другой банк
      internal static let anotherBank = Loc.tr("Localizable", "Acquiring.SBPBanks.AnotherBank", fallback: "Другой банк")
      /// Закрыть
      internal static let buttonClose = Loc.tr("Localizable", "Acquiring.SBPBanks.ButtonClose", fallback: "Закрыть")
    }
  }
  internal enum AcquiringPayment {
    internal enum Button {
      /// Выбрать другую карту
      internal static let chooseCard = Loc.tr("Localizable", "AcquiringPayment.button.chooseCard", fallback: "Выбрать другую карту")
    }
  }
  internal enum CardList {
    internal enum Alert {
      internal enum Action {
        /// Отмена
        internal static let cancel = Loc.tr("Localizable", "CardList.alert.action.cancel", fallback: "Отмена")
        /// Удалить
        internal static let delete = Loc.tr("Localizable", "CardList.alert.action.delete", fallback: "Удалить")
      }
      internal enum Message {
        /// Вы уверены, что хотите удалить карту %@?
        internal static func deleteCard(_ p1: Any) -> String {
          return Loc.tr("Localizable", "CardList.alert.message.deleteCard", String(describing: p1), fallback: "Вы уверены, что хотите удалить карту %@?")
        }
      }
      internal enum Title {
        /// Удаление карты
        internal static let deleteCard = Loc.tr("Localizable", "CardList.alert.title.deleteCard", fallback: "Удаление карты")
      }
    }
    internal enum Button {
      /// Добавить новую карту
      internal static let addNewCard = Loc.tr("Localizable", "CardList.button.addNewCard", fallback: "Добавить новую карту")
      /// Другой картой
      internal static let anotherCard = Loc.tr("Localizable", "CardList.button.anotherCard", fallback: "Другой картой")
    }
    internal enum Screen {
      internal enum Title {
        /// Оплата картой
        internal static let paymentByCard = Loc.tr("Localizable", "CardList.screen.title.paymentByCard", fallback: "Оплата картой")
      }
    }
    internal enum Status {
      /// У вас нет сохраненных карт
      internal static let noCards = Loc.tr("Localizable", "CardList.status.noCards", fallback: "У вас нет сохраненных карт")
    }
  }
  internal enum CommonAlert {
    /// Понятно
    internal static let button = Loc.tr("Localizable", "CommonAlert.Button", fallback: "Понятно")
    internal enum AddCard {
      /// Карта уже добавлена
      internal static let title = Loc.tr("Localizable", "CommonAlert.AddCard.Title", fallback: "Карта уже добавлена")
    }
    internal enum DeleteCard {
      /// Не получилось удалить карту
      internal static let title = Loc.tr("Localizable", "CommonAlert.DeleteCard.Title", fallback: "Не получилось удалить карту")
    }
    internal enum SBPNoBank {
      /// Установите его или выберите другой банк
      internal static let description = Loc.tr("Localizable", "CommonAlert.SBPNoBank.Description", fallback: "Установите его или выберите другой банк")
      /// Не получилось найти приложение этого банка
      internal static let title = Loc.tr("Localizable", "CommonAlert.SBPNoBank.Title", fallback: "Не получилось найти приложение этого банка")
    }
    internal enum SomeProblem {
      /// Попробуйте снова через пару минут
      internal static let description = Loc.tr("Localizable", "CommonAlert.SomeProblem.Description", fallback: "Попробуйте снова через пару минут")
      /// У нас проблема, мы уже решаем ее
      internal static let title = Loc.tr("Localizable", "CommonAlert.SomeProblem.Title", fallback: "У нас проблема, мы уже решаем ее")
    }
  }
  internal enum CommonSheet {
    internal enum Paid {
      /// Понятно
      internal static let primaryButton = Loc.tr("Localizable", "CommonSheet.Paid.PrimaryButton", fallback: "Понятно")
      /// Оплачено
      internal static let title = Loc.tr("Localizable", "CommonSheet.Paid.Title", fallback: "Оплачено")
    }
    internal enum PaymentFailed {
      /// Попробуйте другой способ оплаты
      internal static let description = Loc.tr("Localizable", "CommonSheet.PaymentFailed.Description", fallback: "Попробуйте другой способ оплаты")
      /// Выбрать другой способ
      internal static let primaryButton = Loc.tr("Localizable", "CommonSheet.PaymentFailed.PrimaryButton", fallback: "Выбрать другой способ")
      /// Ошибка при оплате
      internal static let title = Loc.tr("Localizable", "CommonSheet.PaymentFailed.Title", fallback: "Ошибка при оплате")
    }
    internal enum PaymentWaiting {
      /// Закрыть
      internal static let secondaryButton = Loc.tr("Localizable", "CommonSheet.PaymentWaiting.SecondaryButton", fallback: "Закрыть")
      /// Ждем оплату в приложении банка
      internal static let title = Loc.tr("Localizable", "CommonSheet.PaymentWaiting.Title", fallback: "Ждем оплату в приложении банка")
    }
    internal enum Processing {
      /// Это займет некоторое время
      internal static let description = Loc.tr("Localizable", "CommonSheet.Processing.Description", fallback: "Это займет некоторое время")
      /// Обрабатываем платеж
      internal static let title = Loc.tr("Localizable", "CommonSheet.Processing.Title", fallback: "Обрабатываем платеж")
    }
    internal enum TimeoutFailed {
      /// Попробуйте оплатить снова
      internal static let description = Loc.tr("Localizable", "CommonSheet.TimeoutFailed.Description", fallback: "Попробуйте оплатить снова")
      /// Закрыть
      internal static let secondaryButton = Loc.tr("Localizable", "CommonSheet.TimeoutFailed.SecondaryButton", fallback: "Закрыть")
      /// Время оплаты истекло
      internal static let title = Loc.tr("Localizable", "CommonSheet.TimeoutFailed.Title", fallback: "Время оплаты истекло")
    }
  }
  internal enum CommonStub {
    internal enum NoCards {
      /// Добавить
      internal static let button = Loc.tr("Localizable", "CommonStub.NoCards.Button", fallback: "Добавить")
      /// Здесь будут ваши карты
      internal static let description = Loc.tr("Localizable", "CommonStub.NoCards.Description", fallback: "Здесь будут ваши карты")
    }
    internal enum NoNetwork {
      /// Обновить
      internal static let button = Loc.tr("Localizable", "CommonStub.NoNetwork.Button", fallback: "Обновить")
      /// Проверьте доступ к интернету и попробуйте еще раз
      internal static let description = Loc.tr("Localizable", "CommonStub.NoNetwork.Description", fallback: "Проверьте доступ к интернету и попробуйте еще раз")
      /// Не загрузилось
      internal static let title = Loc.tr("Localizable", "CommonStub.NoNetwork.Title", fallback: "Не загрузилось")
    }
    internal enum SomeProblem {
      /// Понятно
      internal static let button = Loc.tr("Localizable", "CommonStub.SomeProblem.Button", fallback: "Понятно")
      /// Попробуйте снова через пару минут
      internal static let description = Loc.tr("Localizable", "CommonStub.SomeProblem.Description", fallback: "Попробуйте снова через пару минут")
      /// У нас проблема, мы уже решаем ее
      internal static let title = Loc.tr("Localizable", "CommonStub.SomeProblem.Title", fallback: "У нас проблема, мы уже решаем ее")
    }
  }
  internal enum Sbp {
    internal enum BanksList {
      internal enum Button {
        /// Продолжить
        internal static let title = Loc.tr("Localizable", "SBP.BanksList.Button.Title", fallback: "Продолжить")
      }
      internal enum Header {
        /// Мы откроем приложение этого банка для подтверждения оплаты
        internal static let subtitle = Loc.tr("Localizable", "SBP.BanksList.Header.Subtitle", fallback: "Мы откроем приложение этого банка для подтверждения оплаты")
        /// Выбор банка
        internal static let title = Loc.tr("Localizable", "SBP.BanksList.Header.Title", fallback: "Выбор банка")
      }
    }
    internal enum EmptyBanks {
      /// Для оплаты через СБП необходимо иметь установленными банковские приложения
      internal static let description = Loc.tr("Localizable", "SBP.EmptyBanks.Description", fallback: "Для оплаты через СБП необходимо иметь установленными банковские приложения")
      /// Не найдено ни одного банковского приложения
      internal static let title = Loc.tr("Localizable", "SBP.EmptyBanks.Title", fallback: "Не найдено ни одного банковского приложения")
      internal enum ConfirmationButton {
        /// Понятно
        internal static let title = Loc.tr("Localizable", "SBP.EmptyBanks.ConfirmationButton.Title", fallback: "Понятно")
      }
      internal enum InformationButton {
        /// Информация на сайте СБП
        internal static let title = Loc.tr("Localizable", "SBP.EmptyBanks.InformationButton.Title", fallback: "Информация на сайте СБП")
      }
    }
    internal enum Error {
      /// Попробуйте еще раз
      internal static let description = Loc.tr("Localizable", "SBP.Error.Description", fallback: "Попробуйте еще раз")
      /// Не удалось выполнить оплату через СБП
      internal static let title = Loc.tr("Localizable", "SBP.Error.Title", fallback: "Не удалось выполнить оплату через СБП")
    }
    internal enum LoadingStatus {
      /// Ожидаем подтверждения платежа
      internal static let title = Loc.tr("Localizable", "SBP.LoadingStatus.Title", fallback: "Ожидаем подтверждения платежа")
    }
    internal enum OpenApplication {
      /// Не удалось открыть приложение
      internal static let error = Loc.tr("Localizable", "SBP.OpenApplication.Error", fallback: "Не удалось открыть приложение")
    }
  }
  internal enum Tp {
    internal enum Error {
      /// Попробуйте еще раз
      internal static let description = Loc.tr("Localizable", "TP.Error.Description", fallback: "Попробуйте еще раз")
      /// Не удалось выполнить оплату через Tinkoff Pay
      internal static let title = Loc.tr("Localizable", "TP.Error.Title", fallback: "Не удалось выполнить оплату через Tinkoff Pay")
    }
    internal enum LoadingStatus {
      /// Ожидаем подтверждения платежа
      internal static let title = Loc.tr("Localizable", "TP.LoadingStatus.Title", fallback: "Ожидаем подтверждения платежа")
    }
    internal enum NoTinkoffBankApp {
      /// Скачайте приложение или выберите другой способ оплаты
      internal static let description = Loc.tr("Localizable", "TP.NoTinkoffBankApp.Description", fallback: "Скачайте приложение или выберите другой способ оплаты")
      /// У вас не установлено Tinkoff
      internal static let title = Loc.tr("Localizable", "TP.NoTinkoffBankApp.Title", fallback: "У вас не установлено Tinkoff")
      internal enum Button {
        /// Установить
        internal static let install = Loc.tr("Localizable", "TP.NoTinkoffBankApp.Button.Install", fallback: "Установить")
        /// Отменить
        internal static let сancel = Loc.tr("Localizable", "TP.NoTinkoffBankApp.Button.Сancel", fallback: "Отменить")
      }
    }
  }
  internal enum TinkoffAcquiring {
    internal enum Alert {
      internal enum Message {
        /// Операция отменена
        internal static let addingCardCancel = Loc.tr("Localizable", "TinkoffAcquiring.alert.message.addingCardCancel", fallback: "Операция отменена")
      }
      internal enum Title {
        /// Добавление карты
        internal static let addingCard = Loc.tr("Localizable", "TinkoffAcquiring.alert.title.addingCard", fallback: "Добавление карты")
        /// Карта добавлена
        internal static let cardSuccessAdded = Loc.tr("Localizable", "TinkoffAcquiring.alert.title.cardSuccessAdded", fallback: "Карта добавлена")
        /// Ошибка
        internal static let error = Loc.tr("Localizable", "TinkoffAcquiring.alert.title.error", fallback: "Ошибка")
      }
    }
    internal enum Button {
      /// Добавить
      internal static let addCard = Loc.tr("Localizable", "TinkoffAcquiring.button.addCard", fallback: "Добавить")
      /// Отмена
      internal static let cancel = Loc.tr("Localizable", "TinkoffAcquiring.button.cancel", fallback: "Отмена")
      /// Закрыть
      internal static let close = Loc.tr("Localizable", "TinkoffAcquiring.button.close", fallback: "Закрыть")
      /// Подтвердить
      internal static let confirm = Loc.tr("Localizable", "TinkoffAcquiring.button.confirm", fallback: "Подтвердить")
      /// Удалить
      internal static let delete = Loc.tr("Localizable", "TinkoffAcquiring.button.delete", fallback: "Удалить")
      /// Ok
      internal static let ok = Loc.tr("Localizable", "TinkoffAcquiring.button.ok", fallback: "Ok")
      /// Оплатить через 
      internal static let payBy = Loc.tr("Localizable", "TinkoffAcquiring.button.payBy", fallback: "Оплатить через ")
      /// Оплатить по карте
      internal static let payByCard = Loc.tr("Localizable", "TinkoffAcquiring.button.payByCard", fallback: "Оплатить по карте")
      /// QR-код
      internal static let qrcode = Loc.tr("Localizable", "TinkoffAcquiring.button.qrcode", fallback: "QR-код")
      /// Обновить
      internal static let update = Loc.tr("Localizable", "TinkoffAcquiring.button.update", fallback: "Обновить")
    }
    internal enum Error {
      /// укажите сумму с точностью до копеек
      internal static let loopAmount = Loc.tr("Localizable", "TinkoffAcquiring.error.loopAmount", fallback: "укажите сумму с точностью до копеек")
    }
    internal enum Hint {
      /// сумма с точностью до копеек
      internal static let loopAmount = Loc.tr("Localizable", "TinkoffAcquiring.hint.loopAmount", fallback: "сумма с точностью до копеек")
    }
    internal enum Placeholder {
      /// Номер карты
      internal static let cardNumber = Loc.tr("Localizable", "TinkoffAcquiring.placeholder.cardNumber", fallback: "Номер карты")
      /// Например 0,89
      internal static let loopAmount = Loc.tr("Localizable", "TinkoffAcquiring.placeholder.loopAmount", fallback: "Например 0,89")
      /// Отправить квитанцию по адресу
      internal static let sendReceiptToEmail = Loc.tr("Localizable", "TinkoffAcquiring.placeholder.sendReceiptToEmail", fallback: "Отправить квитанцию по адресу")
    }
    internal enum Text {
      /// Добавить карту
      internal static let addcard = Loc.tr("Localizable", "TinkoffAcquiring.text.addcard", fallback: "Добавить карту")
      /// Добавить новую карту
      internal static let addNewCard = Loc.tr("Localizable", "TinkoffAcquiring.text.addNewCard", fallback: "Добавить новую карту")
      /// Для подтверждения операции мы списали и вернули небольшую сумму (до 1,99 руб.)
      /// Пожалуйста, укажите ее с точностью до копеек.
      internal static let loopConfirmation = Loc.tr("Localizable", "TinkoffAcquiring.text.loopConfirmation", fallback: "Для подтверждения операции мы списали и вернули небольшую сумму (до 1,99 руб.)\nПожалуйста, укажите ее с точностью до копеек.")
      /// или
      internal static let or = Loc.tr("Localizable", "TinkoffAcquiring.text.or", fallback: "или")
      internal enum Status {
        /// Сохраненных карт нет
        internal static let cardListEmpty = Loc.tr("Localizable", "TinkoffAcquiring.text.status.cardListEmpty", fallback: "Сохраненных карт нет")
        /// Загрузка ...
        internal static let loading = Loc.tr("Localizable", "TinkoffAcquiring.text.status.loading", fallback: "Загрузка ...")
        /// Выбор источника оплаты
        internal static let selectingPaymentSource = Loc.tr("Localizable", "TinkoffAcquiring.text.status.selectingPaymentSource", fallback: "Выбор источника оплаты")
        /// Инициалихация платежа
        internal static let waitingInitPayment = Loc.tr("Localizable", "TinkoffAcquiring.text.status.waitingInitPayment", fallback: "Инициалихация платежа")
        /// Ожидание оплаты
        internal static let waitingPayment = Loc.tr("Localizable", "TinkoffAcquiring.text.status.waitingPayment", fallback: "Ожидание оплаты")
        internal enum Error {
          /// Неверный формат электронной почты
          internal static let email = Loc.tr("Localizable", "TinkoffAcquiring.text.status.error.email", fallback: "Неверный формат электронной почты")
          /// Введите email
          internal static let emailEmpty = Loc.tr("Localizable", "TinkoffAcquiring.text.status.error.emailEmpty", fallback: "Введите email")
        }
      }
    }
    internal enum Threeds {
      /// Подтверждение
      internal static let acceptAuth = Loc.tr("Localizable", "TinkoffAcquiring.threeds.acceptAuth", fallback: "Подтверждение")
      /// Отменить
      internal static let cancelAuth = Loc.tr("Localizable", "TinkoffAcquiring.threeds.cancelAuth", fallback: "Отменить")
      internal enum Error {
        /// Платежная система не поддерживается
        internal static let invalidPaymentSystem = Loc.tr("Localizable", "TinkoffAcquiring.threeds.error.invalidPaymentSystem", fallback: "Платежная система не поддерживается")
        /// Превышено маскимальное время прохождения 3DS
        internal static let timeout = Loc.tr("Localizable", "TinkoffAcquiring.threeds.error.timeout", fallback: "Превышено маскимальное время прохождения 3DS")
        /// Не удалось обновить сертификаты
        internal static let updatingCertsError = Loc.tr("Localizable", "TinkoffAcquiring.threeds.error.updatingCertsError", fallback: "Не удалось обновить сертификаты")
      }
    }
    internal enum Unknown {
      internal enum Error {
        /// Неизвесная ошибка.
        /// Попробуйте поворить операцию.
        internal static let status = Loc.tr("Localizable", "TinkoffAcquiring.unknown.error.status", fallback: "Неизвесная ошибка.\nПопробуйте поворить операцию.")
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
        internal static let status = Loc.tr("Localizable", "TinkoffAcquiring.unknown.response.status", fallback: "Неизвестный статус платежа")
      }
    }
    internal enum View {
      internal enum Title {
        /// Подтверждение
        internal static let confimration = Loc.tr("Localizable", "TinkoffAcquiring.view.title.confimration", fallback: "Подтверждение")
        /// Оплата
        internal static let pay = Loc.tr("Localizable", "TinkoffAcquiring.view.title.pay", fallback: "Оплата")
        /// Оплата по QR-коду
        internal static let payQRCode = Loc.tr("Localizable", "TinkoffAcquiring.view.title.payQRCode", fallback: "Оплата по QR-коду")
        /// Сохраненные карты
        internal static let savedCards = Loc.tr("Localizable", "TinkoffAcquiring.view.title.savedCards", fallback: "Сохраненные карты")
      }
    }
  }
  internal enum YandexSheet {
    internal enum Failed {
      /// Воспользуйтесь другим способом оплаты
      internal static let description = Loc.tr("Localizable", "YandexSheet.Failed.Description", fallback: "Воспользуйтесь другим способом оплаты")
      /// Понятно
      internal static let primaryButton = Loc.tr("Localizable", "YandexSheet.Failed.PrimaryButton", fallback: "Понятно")
      /// Не получилось оплатить
      internal static let title = Loc.tr("Localizable", "YandexSheet.Failed.Title", fallback: "Не получилось оплатить")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Loc {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = Bundle.uiResources.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
